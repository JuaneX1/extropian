import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> devicesList = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  // Start scanning for Bluetooth devices
  void startScan() {
    if (!isScanning) {
      setState(() {
        isScanning = true;
        devicesList.clear(); // Clear previous scan results
      });

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {

          // Combine the device name and the advertisement localName
          final deviceName = result.device.name.isNotEmpty 
              ? result.device.name 
              : result.advertisementData.localName;

    // Skip if both are empty
    if (deviceName.isEmpty) continue;
          if (!devicesList.any((d) => d.id == result.device.id)) {
            setState(() {
              devicesList.add(result.device);
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

  // Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${device.name.isNotEmpty ? device.name : "Unknown Device"}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bluetooth Icon
            const Icon(Icons.bluetooth_audio, size: 100, color: Colors.blueAccent),
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

            // Button: Relocate Device (Dummy Action)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Relocating Device")),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Relocate Device",
                style: GoogleFonts.tomorrow(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
