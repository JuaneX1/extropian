import 'dart:math';

class DataFrame {
  final Map<String, List<dynamic>> _columns = {};

  void addColumn(String name, List<dynamic> values) {
    _columns[name] = values;
  }

  List<dynamic>? getColumn(String name) {
    return _columns[name];
  }

  int get rowCount => _columns.isNotEmpty ? _columns.values.first.length : 0;
}

class Calculations {
  static double speedWithGyro(DataFrame device2Df) {
    const double stationaryThreshold = 16.0;
    const double rotationThreshold = 0.1;
    const double adjustmentFactor = 0.8;

    // Calculate time intervals (in seconds)
    List<int> timestamps = List<int>.from(device2Df.getColumn("Timestamp")!);
    List<double> dtColumn = [0.0];

    for (int i = 1; i < timestamps.length; i++) {
      double dt = (timestamps[i] - timestamps[i - 1]) / 1000.0;
      dtColumn.add(dt);
    }
    device2Df.addColumn("dt", dtColumn);

    // Identify stationary periods
    List<double> linAccelMag = List<double>.from(device2Df.getColumn("LinearAccelMagnitude")!);
    List<bool> stationaryColumn = linAccelMag.map((value) => value < stationaryThreshold).toList();
    device2Df.addColumn("Stationary", stationaryColumn);

    // Initialize speed and deceleration columns
    List<double> speedColumn = [0.0];
    List<bool> deceleratingColumn = [false];

    // Compute angular velocity magnitude from gyroscope data
    List<double> gyroX = List<double>.from(device2Df.getColumn("GyroX")!);
    List<double> gyroY = List<double>.from(device2Df.getColumn("GyroY")!);
    List<double> gyroZ = List<double>.from(device2Df.getColumn("GyroZ")!);

    List<double> angularVelocityMagColumn = [];
    for (int i = 0; i < gyroX.length; i++) {
      double angularVelocityMag = sqrt(pow(gyroX[i], 2) + pow(gyroY[i], 2) + pow(gyroZ[i], 2));
      angularVelocityMagColumn.add(angularVelocityMag);
    }
    device2Df.addColumn("AngularVelocityMagnitude", angularVelocityMagColumn);

    // Compute speed
    for (int i = 1; i < linAccelMag.length; i++) {
      bool isStationary = stationaryColumn[i];
      if (!isStationary) {
        double prevSpeed = speedColumn[i - 1];
        double acceleration = linAccelMag[i];
        double angularVelocityMag = angularVelocityMagColumn[i];

        if (angularVelocityMag > rotationThreshold) {
          acceleration *= adjustmentFactor;
        }

        double dt = dtColumn[i];
        double newSpeed = prevSpeed + acceleration * dt;

        speedColumn.add(newSpeed);
        deceleratingColumn.add(newSpeed < prevSpeed);
      } else {
        speedColumn.add(0.0);
        deceleratingColumn.add(false);
      }
    }
    device2Df.addColumn("Speed", speedColumn);
    device2Df.addColumn("Decelerating", deceleratingColumn);

    return speedColumn.reduce(max);
  }

  static (double, double, double, int?) calculateMetrics(
    double maxSpeed,
    double backswingRotation,
    double frontswingRotation,
    int speedTimestamp,
    int? minYawTimestamp,
  ) {
    double maxSpeedMph = (maxSpeed / 1.5) * 2.236936;
    double clubheadSpeed = maxSpeedMph * 2.5;

    double fullSwingRotation = frontswingRotation - backswingRotation;

    int? swingLag = minYawTimestamp != null ? speedTimestamp - minYawTimestamp : null;

    return (maxSpeedMph, clubheadSpeed, fullSwingRotation, swingLag);
  }

  static (double, double, int?, int?) calculateHipRotation(DataFrame device1Df) {
    List<int> timestamps = List<int>.from(device1Df.getColumn("Timestamp")!);
    List<double> yawColumn = List<double>.from(device1Df.getColumn("Yaw")!);

    List<double> unwrappedYaw = [yawColumn.first];
    for (int i = 1; i < yawColumn.length; i++) {
      double diff = yawColumn[i] - yawColumn[i - 1];
      if (diff > 180) {
        unwrappedYaw.add(unwrappedYaw.last + (yawColumn[i] - 360));
      } else if (diff < -180) {
        unwrappedYaw.add(unwrappedYaw.last + (yawColumn[i] + 360));
      } else {
        unwrappedYaw.add(yawColumn[i]);
      }
    }

    double minYaw = unwrappedYaw.reduce(min);
    double maxYaw = unwrappedYaw.reduce(max);
    int? minYawTimestamp = timestamps[unwrappedYaw.indexOf(minYaw)];
    int? maxYawTimestamp = timestamps[unwrappedYaw.indexOf(maxYaw)];

    return (minYaw, maxYaw, minYawTimestamp, maxYawTimestamp);
  }

  static (double, double) calculatePreSwingPosture(DataFrame device1Df) {
    List<double> rollColumn = List<double>.from(device1Df.getColumn("Roll")!);
    Map<double, int> frequencyMap = {};

    for (double value in rollColumn) {
      double roundedValue = value.roundToDouble();
      frequencyMap[roundedValue] = (frequencyMap[roundedValue] ?? 0) + 1;
    }

    List<double> sortedKeys = frequencyMap.keys.toList()
      ..sort((a, b) => frequencyMap[b]!.compareTo(frequencyMap[a]!));

    return (
      sortedKeys.isNotEmpty ? sortedKeys[0] : 0.0,
      sortedKeys.length > 1 ? sortedKeys[1] : 0.0,
    );
  }
}
