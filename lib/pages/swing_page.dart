import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import '../algorithms/calculations.dart';
import 'bluetooth_provider.dart';



class SwingPage extends StatefulWidget {
  const SwingPage({super.key});

  @override
  _SwingPageState createState() => _SwingPageState();
}

class _SwingPageState extends State<SwingPage> {
  String characteristicStatus = "Press Start to capture raw packets.";
  final List<List<int>> _rawPackets = [];
  Map<int, SensorDataRow> _parsedDataMap = {};
  Map<String, dynamic>? _swingMetrics;
  StreamSubscription<List<int>>? _subscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  String? selectedClub;
  final Map<String, String> clubMapping = {
    'D': 'Driver',
    '3W': '3 Wood',
    '3I': '3 Iron',
    '4I': '4 Iron',
    '5I': '5 Iron',
    '6I': '6 Iron',
    '7I': '7 Iron',
    '8I': '8 Iron',
    '9I': '9 Iron',
    'PW': 'Pitching Wedge',
    'SW': 'Sand Wedge',
    '60°': '60 Degree'
  };
  Future<void> _saveSelectedClub() async {
    if (selectedClub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a golf club')),
      );
      return;
    }

    String fullClubName = clubMapping[selectedClub] ?? selectedClub!;
    String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    try {
      var dateDocRef = _firestore
          .collection('users_swings')
          .doc(_user?.uid)
          .collection(fullClubName)
          .doc(currentDate);


      // Get existing document to check totalSwings count
      var docSnapshot = await dateDocRef.get();
      int newSwingNumber = 1;

      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null && data.containsKey('totalSwings')) {
          newSwingNumber = (data['totalSwings'] as int) + 1;
        }
        await dateDocRef.update({'totalSwings': newSwingNumber});
      } else {
        await dateDocRef.set({'totalSwings': newSwingNumber});
      }
      double wristSpeed = _swingMetrics!["maxWristSpeed_mph"];
      double clubHeadSpeed = _swingMetrics!["clubheadSpeed_mph"];

      await dateDocRef.collection('swings').doc(newSwingNumber.toString()).set({
            'wrist_speed': wristSpeed,
            'club_head_speed': clubHeadSpeed,
            'hip_rotation': 0,
            'start_end_rotation': 0,
            'hip_wrist_lag': 0,
            'back_posture': 0,
            'date': FieldValue.serverTimestamp(),
      });



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Swing $newSwingNumber added under "$fullClubName/$currentDate"!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save swing: $e')),
      );
    }
  }

  // Start capturing raw packets from the target characteristic
  Future<void> _startPacketCapture() async {
    BluetoothDevice? device =
        Provider.of<BluetoothProvider>(context, listen: false).connectedDevice;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Bluetooth device connected.")),
      );
      return;
    }

    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? targetCharacteristic;

      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() ==
            'f000e140-0451-4000-b000-000000000000') {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                'f000e147-0451-4000-b000-000000000000') {
              targetCharacteristic = characteristic;
              break;
            }
          }
        }
        if (targetCharacteristic != null) break;
      }

      if (targetCharacteristic != null) {
        await targetCharacteristic.setNotifyValue(true);
        setState(() {
          characteristicStatus = "Capturing raw packets...";
          _rawPackets.clear();
        });
        _subscription = targetCharacteristic.value.listen((data) {
          setState(() {
            _rawPackets.add(data);
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Started capturing packets.")),
        );
      } else {
        setState(() {
          characteristicStatus = "Characteristic not found.";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Characteristic not found.")),
        );
      }
    } catch (e) {
      setState(() {
        characteristicStatus = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing packets: $e")),
      );
    }
  }

  // Stop capturing packets, parse them, and compute swing metrics.
  void _stopPacketCapture() {
    _subscription?.cancel();

    // Parse the raw packets into a map keyed by timestamp.
    final parsedMap = parseAllPackets(_rawPackets);

    // Convert parsedMap to a sorted list.
    final sortedRows = parsedMap.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate swing metrics (wrist speed, clubhead speed, etc.)
    final metrics = calculateWristAndClubSpeed(sortedRows);

    setState(() {
      characteristicStatus =
          "Packet capture stopped. Parsed ${parsedMap.length} timestamps.";
      _parsedDataMap = parsedMap;
      _swingMetrics = metrics;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Stopped capturing packets. Found ${parsedMap.length} rows.")),
    );
    _saveSelectedClub();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BluetoothDevice? device =
        Provider.of<BluetoothProvider>(context).connectedDevice;
    String deviceName = device != null
        ? (device.name.isNotEmpty ? device.name : "Unknown Device")
        : "No Device Connected";

    // Convert parsed data to sorted list for table display.
    final sortedRows = _parsedDataMap.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Swing Page", style: GoogleFonts.tomorrow(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Device info
            Center(
              child: Text("Connected Device: $deviceName",
                  style: GoogleFonts.tomorrow(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            // Buttons to start/stop capture
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startPacketCapture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8A42D),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Start", style: GoogleFonts.tomorrow(fontSize: 16)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _stopPacketCapture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Stop", style: GoogleFonts.tomorrow(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status display
            Text(characteristicStatus,
                style: GoogleFonts.tomorrow(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            // Swing metrics boxes
            if (_swingMetrics != null)
              Column(
                children: [
                  MetricBox(
                      title: "Wrist Speed (m/s)",
                      value: _swingMetrics!["maxWristSpeed_m_s"].toStringAsFixed(2)),
                  const SizedBox(height: 8),
                  MetricBox(
                      title: "Wrist Speed (mph)",
                      value: _swingMetrics!["maxWristSpeed_mph"].toStringAsFixed(2)),
                  const SizedBox(height: 8),
                  MetricBox(
                      title: "Clubhead Speed (mph)",
                      value: _swingMetrics!["clubheadSpeed_mph"].toStringAsFixed(2)),
                ],
              ),
            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: clubMapping.keys.map((club) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(club, style: GoogleFonts.tomorrow(color: Colors.white)),
                        selected: selectedClub == club,
                        onSelected: (isSelected) {
                          setState(() {
                            selectedClub = club;
                          });
                        },
                        backgroundColor: Colors.grey[700],
                        selectedColor: Color(0xFFD8A42D),
                      ),
                    )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // A sliver-like area to scroll through parsed packet rows (table)
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[900],
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
                        _buildColumn("Timestamp"),
                        _buildColumn("AccelX"),
                        _buildColumn("AccelY"),
                        _buildColumn("AccelZ"),
                        _buildColumn("AccelMag"),
                        _buildColumn("GyroX"),
                        _buildColumn("GyroY"),
                        _buildColumn("GyroZ"),
                        _buildColumn("MagX"),
                        _buildColumn("MagY"),
                        _buildColumn("MagZ"),
                        _buildColumn("Yaw"),
                        _buildColumn("Pitch"),
                        _buildColumn("Roll"),
                      ],
                      rows: sortedRows.map((row) {
                        return DataRow(cells: [
                          _buildCell("${row.timestamp}"),
                          _buildCell("${row.accelX?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.accelY?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.accelZ?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.accelMag?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.gyroX?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.gyroY?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.gyroZ?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.magnetX?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.magnetY?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.magnetZ?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.yaw?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.pitch?.toStringAsFixed(2) ?? ""}"),
                          _buildCell("${row.roll?.toStringAsFixed(2) ?? ""}"),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  DataCell _buildCell(String text) {
    return DataCell(Text(text, style: const TextStyle(color: Colors.white)));
  }
}

/// A simple widget for displaying a metric in a box.
class MetricBox extends StatelessWidget {
  final String title;
  final String value;
  const MetricBox({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.tomorrow(fontSize: 16, color: Colors.white70)),
          Text(value,
              style: GoogleFonts.tomorrow(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
