// calculations.dart
import 'dart:typed_data';
import 'dart:math';

/// A row of sensor data, keyed by timestamp.
class SensorDataRow {
  final int timestamp;

  // Accelerometer
  double? accelX;
  double? accelY;
  double? accelZ;
  double? accelMag; // sqrt(x² + y² + z²)

  // Gyroscope
  double? gyroX;
  double? gyroY;
  double? gyroZ;

  // Magnetometer
  double? magnetX;
  double? magnetY;
  double? magnetZ;

  // Rotation Vector (converted to Euler angles)
  double? yaw;
  double? pitch;
  double? roll;

  SensorDataRow(this.timestamp);
}

/// Parse all raw packets and merge them into a map keyed by timestamp.
Map<int, SensorDataRow> parseAllPackets(List<List<int>> rawPackets) {
  final dataMap = <int, SensorDataRow>{};

  for (final packet in rawPackets) {
    _parseSensorPacket(packet, dataMap);
  }

  return dataMap;
}

/// Identify the sensor type from the first byte (0x08, 0x09, 0x0A)
/// then parse and store the results in [dataMap].
void _parseSensorPacket(List<int> packet, Map<int, SensorDataRow> dataMap) {
  if (packet.isEmpty) return;
  final bytes = Uint8List.fromList(packet);

  final sensorType = bytes[0];
  // Only parse if it's one of the known sensor types (accel, gyro/mag, RV).
  if (sensorType != 0x08 && sensorType != 0x09 && sensorType != 0x0A) {
    return;
  }

  switch (sensorType) {
    case 0x08:
      _parseGyroMagnet(bytes, dataMap);
      break;
    case 0x09:
      _parseAccel(bytes, dataMap);
      break;
    case 0x0A:
      _parseRV(bytes, dataMap);
      break;
  }
}

/// Parse Accelerometer (0x09) packets.
void _parseAccel(Uint8List bytes, Map<int, SensorDataRow> dataMap) {
  if (bytes.length < 13) return;

  final xRaw = _toSigned16(bytes[2], bytes[3]);
  final yRaw = _toSigned16(bytes[4], bytes[5]);
  final zRaw = _toSigned16(bytes[6], bytes[7]);
  final timestamp = _toSigned32(bytes[9], bytes[10], bytes[11], bytes[12]);

  final x = bnoQToFloat(xRaw, -8);
  final y = bnoQToFloat(yRaw, -8);
  final z = bnoQToFloat(zRaw, -8);

  // Calculate acceleration magnitude.
  final mag = sqrt(x * x + y * y + z * z);

  final row = dataMap.putIfAbsent(timestamp, () => SensorDataRow(timestamp));
  row.accelX = x;
  row.accelY = y;
  row.accelZ = z;
  row.accelMag = mag;
}

/// Parse Gyroscope & Magnetometer (0x08) packets.
void _parseGyroMagnet(Uint8List bytes, Map<int, SensorDataRow> dataMap) {
  if (bytes.length < 20) return;

  final gxRaw = _toSigned16(bytes[2], bytes[3]);
  final gyRaw = _toSigned16(bytes[4], bytes[5]);
  final gzRaw = _toSigned16(bytes[6], bytes[7]);
  final mxRaw = _toSigned16(bytes[9], bytes[10]);
  final myRaw = _toSigned16(bytes[11], bytes[12]);
  final mzRaw = _toSigned16(bytes[13], bytes[14]);
  final timestamp = _toSigned32(bytes[16], bytes[17], bytes[18], bytes[19]);

  final gyroX = bnoQToFloat(gxRaw, -9);
  final gyroY = bnoQToFloat(gyRaw, -9);
  final gyroZ = bnoQToFloat(gzRaw, -9);

  final magnetX = bnoQToFloat(mxRaw, -4);
  final magnetY = bnoQToFloat(myRaw, -4);
  final magnetZ = bnoQToFloat(mzRaw, -4);

  final row = dataMap.putIfAbsent(timestamp, () => SensorDataRow(timestamp));
  row.gyroX = gyroX;
  row.gyroY = gyroY;
  row.gyroZ = gyroZ;
  row.magnetX = magnetX;
  row.magnetY = magnetY;
  row.magnetZ = magnetZ;
}

/// Parse Rotation Vector (0x0A) packets and convert i/j/k/real -> yaw/pitch/roll.
void _parseRV(Uint8List bytes, Map<int, SensorDataRow> dataMap) {
  if (bytes.length < 17) return;

  final iRaw = _toSigned16(bytes[2], bytes[3]);
  final jRaw = _toSigned16(bytes[4], bytes[5]);
  final kRaw = _toSigned16(bytes[6], bytes[7]);
  final realRaw = _toSigned16(bytes[8], bytes[9]);
  final timestamp = _toSigned32(bytes[13], bytes[14], bytes[15], bytes[16]);

  final iVal = bnoQToFloat(iRaw, -14);
  final jVal = bnoQToFloat(jRaw, -14);
  final kVal = bnoQToFloat(kRaw, -14);
  final realVal = bnoQToFloat(realRaw, -14);

  // Convert quaternion to yaw, pitch, roll.
  final ypr = _convertQuadToYawPitchRoll(iVal, jVal, kVal, realVal);

  final row = dataMap.putIfAbsent(timestamp, () => SensorDataRow(timestamp));
  row.yaw = ypr[0];
  row.pitch = ypr[1];
  row.roll = ypr[2];
}

/// Converts quaternion (i, j, k, real) to yaw/pitch/roll (in degrees).
List<double> _convertQuadToYawPitchRoll(double i, double j, double k, double real) {
  double norm = sqrt(real * real + i * i + j * j + k * k);
  if (norm == 0) norm = 1;
  double dqw = real / norm;
  double dqx = i / norm;
  double dqy = j / norm;
  double dqz = k / norm;

  // Roll (x-axis rotation)
  double t0 = 2.0 * (dqw * dqx + dqy * dqz);
  double t1 = 1.0 - 2.0 * (dqx * dqx + dqy * dqy);
  double roll = atan2(t0, t1);

  // Pitch (y-axis rotation)
  double t2 = 2.0 * (dqw * dqy - dqz * dqx);
  t2 = t2.clamp(-1.0, 1.0);
  double pitch = asin(t2);

  // Yaw (z-axis rotation)
  double t3 = 2.0 * (dqw * dqz + dqx * dqy);
  double t4 = 1.0 - 2.0 * (dqy * dqy + dqz * dqz);
  double yaw = atan2(t3, t4);

  return [yaw * 180 / pi, pitch * 180 / pi, roll * 180 / pi];
}

/// Converts a fixed-point integer to a float: fixedPoint * 2^nq.
double bnoQToFloat(int fixedPoint, int nq) {
  return fixedPoint * pow(2.0, nq).toDouble();
}

/// Convert two bytes (LSB, MSB) to a signed 16-bit integer.
int _toSigned16(int lsb, int msb) {
  int value = (msb << 8) | lsb;
  if ((value & 0x8000) != 0) {
    value -= 0x10000;
  }
  return value;
}

/// Convert four bytes to a signed 32-bit integer.
int _toSigned32(int b1, int b2, int b3, int b4) {
  int value = (b4 << 24) | (b3 << 16) | (b2 << 8) | b1;
  if ((value & 0x80000000) != 0) {
    value -= 0x100000000;
  }
  return value;
}

/// Calculate wrist speed and clubhead speed from a sorted list of SensorDataRow.
/// Uses integration of the accelerometer magnitude to compute speed (in m/s),
/// converts to mph, and then estimates clubhead speed (as a multiple of wrist speed).
Map<String, dynamic> calculateWristAndClubSpeed(List<SensorDataRow> rows) {
  // Configuration parameters
  double stationaryThreshold = 16.0;
  double rotationThreshold = 0.1;
  double adjustmentFactor = 0.8; // Adjust if rotation is high

  double prevSpeed = 0.0;
  double maxSpeed = 0.0;
  int startTimestamp = -1;

  // Ensure rows are sorted by timestamp
  rows.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  for (int i = 1; i < rows.length; i++) {
    SensorDataRow prevRow = rows[i - 1];
    SensorDataRow currRow = rows[i];

    if (currRow.accelMag == null) continue;
    double dt = (currRow.timestamp - prevRow.timestamp) / 1000.0;

    // If below threshold, treat as stationary (reset speed)
    if (currRow.accelMag! < stationaryThreshold) {
      prevSpeed = 0.0;
      continue;
    }

    double angularVelocityMag = 0.0;
    if (currRow.gyroX != null && currRow.gyroY != null && currRow.gyroZ != null) {
      angularVelocityMag = sqrt(pow(currRow.gyroX!, 2) +
                                pow(currRow.gyroY!, 2) +
                                pow(currRow.gyroZ!, 2));
    }

    double acceleration = currRow.accelMag!;
    if (angularVelocityMag > rotationThreshold) {
      acceleration *= adjustmentFactor;
    }

    double newSpeed = prevSpeed + acceleration * dt;
    if (newSpeed > maxSpeed) {
      maxSpeed = newSpeed;
      if (startTimestamp < 0) {
        startTimestamp = currRow.timestamp;
      }
    }
    prevSpeed = newSpeed;
  }

  // Convert m/s to mph (1 m/s ≈ 2.23694 mph)
  double wristSpeedMph = maxSpeed * 2.23694;
  // Estimate clubhead speed as a multiple of wrist speed (e.g. 2.5 times)
  double clubheadSpeedMph = wristSpeedMph * 1.8;

  return {
    "maxWristSpeed_m_s": maxSpeed,
    "maxWristSpeed_mph": wristSpeedMph,
    "clubheadSpeed_mph": clubheadSpeedMph,
    "speedStartTimestamp": startTimestamp
  };
}
