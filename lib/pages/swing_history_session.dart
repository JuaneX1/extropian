import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionSwingsScreen extends StatefulWidget {
  final String clubName;
  final String date;

  const SessionSwingsScreen({
    super.key,
    required this.clubName,
    required this.date,
  });

  @override
  State<SessionSwingsScreen> createState() => _SessionSwingsScreenState();
}

class _SessionSwingsScreenState extends State<SessionSwingsScreen> {
  String selectedMetric = 'wrist_speed'; // Default metric
  int currentIndex = 0; // Current shot index
  List<_ChartData> chartData = [];
  List<Map<String, dynamic>> swings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSwings();
  }

  Future<void> _fetchSwings() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final swingsRef = firestore
        .collection('users_swings')
        .doc(user.uid)
        .collection(widget.clubName)
        .doc(widget.date)
        .collection('swings');

    final querySnapshot = await swingsRef.get();
    setState(() {
      swings = querySnapshot.docs.map((doc) => doc.data()).toList();
      _updateChartData();
      isLoading = false;
    });
  }

  void _updateChartData() {
    chartData = swings.asMap().entries.map((entry) {
      final index = entry.key;
      final swing = entry.value;
      return _ChartData(
        index: index + 1,
        value: (swing[selectedMetric] ?? 0).toDouble(),
      );
    }).toList();
  }

  double _calculateAverage() {
    if (chartData.isEmpty) return 0.0;
    return chartData.map((data) => data.value).reduce((a, b) => a + b) / chartData.length;
  }

  void _changeShotIndex(int direction) {
    setState(() {
      currentIndex = (currentIndex + direction + swings.length) % swings.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.clubName} - ${widget.date} Swings',
            style: GoogleFonts.tomorrow(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.clubName} - ${widget.date} Swings',
          style: GoogleFonts.tomorrow(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricButton(context, 'Wrist Speed', 'wrist_speed'),
                    _buildMetricButton(context, 'Hip Rotation', 'hip_rotation'),
                    _buildMetricButton(context, 'Club Head Speed', 'club_head_speed'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Average ${selectedMetric.capitalize()}: ${_calculateAverage().toStringAsFixed(2)}',
                  style: GoogleFonts.tomorrow(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SfCartesianChart(
                    backgroundColor: Colors.grey[900],
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: 'Swing Index',
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: selectedMetric.capitalize(),
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    legend: Legend(
                      isVisible: false,
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <LineSeries<_ChartData, int>>[
                      LineSeries<_ChartData, int>(
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.index,
                        yValueMapper: (_ChartData data, _) => data.value,
                        name: selectedMetric.capitalize(),
                        color: Colors.blueAccent,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      LineSeries<_ChartData, int>(
                        dataSource: [chartData[currentIndex]],
                        xValueMapper: (_ChartData data, _) => data.index,
                        yValueMapper: (_ChartData data, _) => data.value,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          color: Colors.red,
                          width: 10,
                          height: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Colors.white),
                    onPressed: () => _changeShotIndex(-1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Shot ${currentIndex + 1}',
                      style: GoogleFonts.tomorrow(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: Colors.white),
                    onPressed: () => _changeShotIndex(1),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMetricCube('Wrist Speed', swings[currentIndex]['wrist_speed']),
                        _buildMetricCube('Club Head Speed', swings[currentIndex]['club_head_speed']),
                        _buildMetricCube('Hip Rotation', swings[currentIndex]['hip_rotation']),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMetricCube('Start/End Rotation', swings[currentIndex]['start_end_rotation']),
                        _buildMetricCube('Hip to Wrist Lag', swings[currentIndex]['hip_wrist_lag']),
                        _buildMetricCube('Back Posture', swings[currentIndex]['back_posture']),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricButton(BuildContext context, String label, String metric) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedMetric == metric ? const Color(0xFFD8A42D) : Colors.grey[800],
        foregroundColor: selectedMetric == metric ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () {
        setState(() {
          selectedMetric = metric;
          _updateChartData();
        });
      },
      child: Text(
        label,
        style: GoogleFonts.tomorrow(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricCube(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.tomorrow(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value != null ? value.toStringAsFixed(2) : 'N/A',
              style: GoogleFonts.tomorrow(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final int index;
  final double value;

  _ChartData({required this.index, required this.value});
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}