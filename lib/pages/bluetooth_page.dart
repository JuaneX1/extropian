import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../algorithms/parse_data.dart'; // For parsing raw data
import '../algorithms/calculations.dart'; // For DataFrame & calculations



class SensorReading {
  final int sensorType;
  final List<int> rawData;
  final DateTime timestamp;

  SensorReading({
    required this.sensorType,
    required this.rawData,
  }) : timestamp = DateTime.now();
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> devicesList = [];
  bool isScanning = false;
  String connectedDeviceName = "";
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  BluetoothDevice? lastConnectedDevice;

  DataFrame _device1DataFrame = DataFrame(); // Hip Sensor
  DataFrame _device2DataFrame = DataFrame(); // Wrist Sensor

  String lastHexData = "Waiting for data..."; // For debug

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    if (!isScanning) {
      setState(() {
        isScanning = true;
        devicesList.clear();
        connectedDeviceName = "";
        _connectedDevice = null;
        _services.clear();
      });

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          final deviceName = r.device.name.isNotEmpty
              ? r.device.name
              : r.advertisementData.localName;
          if (deviceName.isEmpty) continue;
          if (!devicesList.any((d) => d.id == r.device.id)) {
            setState(() {
              devicesList.add(r.device);
            });
          }
        }
      });

      Future.delayed(const Duration(seconds: 5), () {
        FlutterBluePlus.stopScan();
        setState(() => isScanning = false);
      });
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _connectedDevice = device;
        lastConnectedDevice = device;
        connectedDeviceName =
            device.name.isNotEmpty ? device.name : "Unknown Device";
      });

      final services = await device.discoverServices();
      setState(() {
        _services = services;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to $connectedDeviceName")),
      );

      _initializeNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    }
  }

  void _initializeNotifications() {
    const String serviceUuid = "f000e140-0451-4000-b000-000000000000";
    const String charUuid = "f000e147-0451-4000-b000-000000000000";

    BluetoothService? sensorService;
    BluetoothCharacteristic? sensorDataChar;

    try {
      sensorService = _services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == serviceUuid,
      );
    } catch (e) {
      debugPrint("Sensor service not found.");
      return;
    }

    try {
      sensorDataChar = sensorService.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == charUuid,
      );
    } catch (e) {
      debugPrint("Sensor data characteristic not found.");
      return;
    }

    if (sensorDataChar.properties.notify) {
      sensorDataChar.setNotifyValue(true);
      sensorDataChar.value.listen((rawData) {
        if (rawData.isNotEmpty) {
          _handleIncomingData(rawData);
        }
      });
    } else {
      debugPrint("Characteristic does not support notify.");
    }
  }

  void _handleIncomingData(List<int> rawData) {
  setState(() {
    // Convert raw data to HEX string for debugging.
    lastHexData = rawData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase();

    // Create SensorReading from raw data
    SensorReading reading = SensorReading(sensorType: rawData[0], rawData: rawData);

    // Convert the SensorReading into a DataFrame
    DataFrame tempDf = buildDataFrame([reading]);

    // Add the parsed DataFrame to the global _dataFrame
    addToDataFrame(tempDf);
  });
}



  Future<void> _disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      setState(() {
        _connectedDevice = null;
        connectedDeviceName = "";
        _services.clear();
        _device1DataFrame = DataFrame();
        _device2DataFrame = DataFrame();
        lastHexData = "Waiting for data...";
      });
    }
  }

  void relocateDevice() {
    if (lastConnectedDevice != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trying to reconnect to ${lastConnectedDevice!.name}...")),
      );
      connectToDevice(lastConnectedDevice!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No last connected device found.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "Bluetooth Setup",
          style: GoogleFonts.tomorrow(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_connectedDevice != null)
            IconButton(
              icon: const Icon(Icons.link_off),
              onPressed: _disconnect,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Display Raw HEX Data
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Incoming HEX Data", style: GoogleFonts.tomorrow(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(lastHexData, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
