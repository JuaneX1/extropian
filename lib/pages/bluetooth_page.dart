import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
<<<<<<< Updated upstream
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
=======
import 'package:provider/provider.dart';
import 'bluetooth_provider.dart';
>>>>>>> Stashed changes

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> devicesList = [];
  bool isScanning = false;
<<<<<<< Updated upstream
  String connectedDeviceName = "";
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  BluetoothDevice? lastConnectedDevice;

  DataFrame _device1DataFrame = DataFrame(); // Hip Sensor
  DataFrame _device2DataFrame = DataFrame(); // Wrist Sensor

  String lastHexData = "Waiting for data..."; // For debug
=======
  String connectedDevice = "";
  BluetoothDevice? lastConnectedDevice;
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
        for (ScanResult r in results) {
          final deviceName = r.device.name.isNotEmpty
              ? r.device.name
              : r.advertisementData.localName;
          if (deviceName.isEmpty) continue;
          if (!devicesList.any((d) => d.id == r.device.id)) {
=======
        for (ScanResult result in results) {
          final deviceName = result.device.name.isNotEmpty
              ? result.device.name
              : result.advertisementData.localName;
          if (deviceName.isEmpty) continue;
          if (!devicesList.any((d) => d.id == result.device.id)) {
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
=======
  // Connect to a Bluetooth device and store it globally
>>>>>>> Stashed changes
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
<<<<<<< Updated upstream
        _connectedDevice = device;
        lastConnectedDevice = device;
        connectedDeviceName =
            device.name.isNotEmpty ? device.name : "Unknown Device";
      });

      final services = await device.discoverServices();
      setState(() {
        _services = services;
      });

=======
        connectedDevice = device.name.isNotEmpty ? device.name : "Unknown Device";
        lastConnectedDevice = device;
      });
      // Set the connected device in the global provider
      Provider.of<BluetoothProvider>(context, listen: false)
          .setConnectedDevice(device);
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
            // Extropian Avatar with label 
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('lib/images/extropianAvatar.png', width: 500),
                const Positioned(
                  left: 135,
                  top: 123,
                  child: Icon(
                    Icons.circle,
                    color: Color(0xFFD8A42D),
                    size: 10,
                  ),
                ),
                const Positioned(
                  left: 120,
                  top: 130,
                  child: Icon(
                    Icons.arrow_upward,
                    color: Color(0xFFD8A42D),
                    size: 40,
                  ),
                ),
                Positioned(
                  left: 100,
                  top: 165,
                  child: Text(
                    "Wrist #1",
                    style: GoogleFonts.tomorrow(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (connectedDevice.isNotEmpty)
                  Positioned(
                    left: 50,
                    bottom: 20,
                    child: Text(
                      "Connected to: $connectedDevice",
                      style: GoogleFonts.tomorrow(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              "Connect to your Smart Device",
              textAlign: TextAlign.center,
              style: GoogleFonts.tomorrow(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle
            Text(
              "Turn on Bluetooth and ensure the device is discoverable.",
              textAlign: TextAlign.center,
              style: GoogleFonts.tomorrow(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            // Bluetooth Devices List
            Expanded(
              child: devicesList.isEmpty
                  ? Center(
                      child: Text(
                        isScanning ? "Scanning..." : "No devices found",
                        style: GoogleFonts.tomorrow(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: devicesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            devicesList[index].name.isNotEmpty
                                ? devicesList[index].name
                                : "Unknown Device",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            devicesList[index].id.toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () => connectToDevice(devicesList[index]),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            // Button: Refresh Devices
            ElevatedButton(
              onPressed: isScanning ? null : startScan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isScanning ? "Scanning..." : "Refresh Devices",
                style: GoogleFonts.tomorrow(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            // Button: Relocate Device
            ElevatedButton(
              onPressed: () {
                if (lastConnectedDevice != null) {
                  connectToDevice(lastConnectedDevice!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No device to relocate. Please connect to a device first.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Relocate Device",
                style: GoogleFonts.tomorrow(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
>>>>>>> Stashed changes
              ),
            ),
          ],
        ),
      ),
    );
  }
}
