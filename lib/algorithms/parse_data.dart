import 'dart:math';
import '../pages/bluetooth_page.dart'; // For SensorReading
import 'calculations.dart'; // For DataFrame



/// Converts two bytes (low, high) into a signed 16-bit integer.
int combineBytes(int low, int high) {
  int result = (high << 8) | low;
  if (result & 0x8000 != 0) {
    result -= 0x10000; // Convert to signed 16-bit value
  }
  return result;
}

/// Parses gyroscope and magnetometer data (Sensor Type 0x08)
Map<String, double> parseGyroMagData(SensorReading reading) {
  if (reading.sensorType != 0x08 || reading.rawData.length < 14) return {};

  return {
    "GyroX": combineBytes(reading.rawData[1], reading.rawData[2]).toDouble(),
    "GyroY": combineBytes(reading.rawData[3], reading.rawData[4]).toDouble(),
    "GyroZ": combineBytes(reading.rawData[5], reading.rawData[6]).toDouble(),
    "MagnetoX": combineBytes(reading.rawData[8], reading.rawData[9]).toDouble(),
    "MagnetoY": combineBytes(reading.rawData[10], reading.rawData[11]).toDouble(),
    "MagnetoZ": combineBytes(reading.rawData[12], reading.rawData[13]).toDouble(),
  };
}

/// Parses accelerometer data (Sensor Type 0x09)
Map<String, double> parseAccelData(SensorReading reading) {
  if (reading.sensorType != 0x09 || reading.rawData.length < 7) return {};

  return {
    "AccelX": combineBytes(reading.rawData[1], reading.rawData[2]).toDouble(),
    "AccelY": combineBytes(reading.rawData[3], reading.rawData[4]).toDouble(),
    "AccelZ": combineBytes(reading.rawData[5], reading.rawData[6]).toDouble(),
  };
}

/// Parses yaw and roll data (Sensor Type 0x07)
Map<String, double> parseOrientationData(SensorReading reading) {
  if (reading.sensorType != 0x07 || reading.rawData.length < 5) return {};

  return {
    "Yaw": combineBytes(reading.rawData[1], reading.rawData[2]).toDouble(),
    "Roll": combineBytes(reading.rawData[3], reading.rawData[4]).toDouble(),
  };
}

/// Converts sensor readings into a structured DataFrame.
DataFrame buildDataFrame(List<SensorReading> readings) {
  DataFrame df = DataFrame();

  List<int> timestamps = [];
  List<double> gyroX = [], gyroY = [], gyroZ = [];
  List<double> magnetoX = [], magnetoY = [], magnetoZ = [];
  List<double> accelX = [], accelY = [], accelZ = [];
  List<double> yaw = [], roll = [];

  for (var reading in readings) {
    timestamps.add(reading.timestamp.millisecondsSinceEpoch);

    if (reading.sensorType == 0x08) {
      var data = parseGyroMagData(reading);
      if (data.isNotEmpty) {
        gyroX.add(data["GyroX"]!);
        gyroY.add(data["GyroY"]!);
        gyroZ.add(data["GyroZ"]!);
        magnetoX.add(data["MagnetoX"]!);
        magnetoY.add(data["MagnetoY"]!);
        magnetoZ.add(data["MagnetoZ"]!);
      }
    } else if (reading.sensorType == 0x09) {
      var data = parseAccelData(reading);
      if (data.isNotEmpty) {
        accelX.add(data["AccelX"]!);
        accelY.add(data["AccelY"]!);
        accelZ.add(data["AccelZ"]!);
      }
    } else if (reading.sensorType == 0x07) {
      var data = parseOrientationData(reading);
      if (data.isNotEmpty) {
        yaw.add(data["Yaw"]!);
        roll.add(data["Roll"]!);
      }
    }
  }

  df.addColumn("Timestamp", timestamps);
  df.addColumn("GyroX", gyroX);
  df.addColumn("GyroY", gyroY);
  df.addColumn("GyroZ", gyroZ);
  df.addColumn("MagnetoX", magnetoX);
  df.addColumn("MagnetoY", magnetoY);
  df.addColumn("MagnetoZ", magnetoZ);
  df.addColumn("AccelX", accelX);
  df.addColumn("AccelY", accelY);
  df.addColumn("AccelZ", accelZ);
  df.addColumn("Yaw", yaw);
  df.addColumn("Roll", roll);

  return df;
}
