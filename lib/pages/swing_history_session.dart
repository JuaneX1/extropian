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
  // Maps Firestore keys to user-friendly labels
  final Map<String, String> metricLabels = {
    'wrist_speed': 'Wrist Speed',
    'hip_rotation': 'Hip Rotation',
    'club_head_speed': 'Club Head Speed',
    'start_end_rotation': 'Start/End Rotation',
    'hip_wrist_lag': 'Hip to Wrist Lag',
    'back_posture': 'Back Posture',
  };

  // Descriptions for the info pop-up
  final Map<String, String> metricDescriptions = {
    'Wrist Speed': 'How quickly the wrists rotate or move during the swing.',
    'Hip Rotation': 'Measures the rotation angle of your hips during the swing.',
    'Club Head Speed': 'The speed of the club head at impact.',
    'Start/End Rotation': 'Tracks the initial and final rotation of the body.',
    'Hip to Wrist Lag': 'Time/angle lag between hip turn and wrist movement.',
    'Back Posture': 'Measures the spine angle and posture throughout the swing.',
  };

  String selectedMetric = 'wrist_speed'; // Default metric for the chart
  int currentIndex = 0;                  // Current shot index
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
      final double value = (swing[selectedMetric] ?? 0).toDouble();
      return _ChartData(index + 1, value);
    }).toList();
  }

  double _calculateAverage() {
    if (chartData.isEmpty) return 0.0;
    final sum = chartData.fold(0.0, (prev, element) => prev + element.value);
    return sum / chartData.length;
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final String chartLabel = metricLabels[selectedMetric] ?? selectedMetric;

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
              // 1) Metric Selection Buttons
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

              // 2) Average text
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Average $chartLabel: ${_calculateAverage().toStringAsFixed(2)}',
                  style: GoogleFonts.tomorrow(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // 3) Spline Chart (smooth/rounded) with current shot highlighted
              SizedBox(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SfCartesianChart(
                    backgroundColor: Colors.grey[900],
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: 'Swing Index',
                        textStyle: GoogleFonts.tomorrow(color: Colors.white),
                      ),
                      labelStyle: GoogleFonts.tomorrow(color: Colors.white),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: chartLabel,
                        textStyle: GoogleFonts.tomorrow(color: Colors.white),
                      ),
                      labelStyle: GoogleFonts.tomorrow(color: Colors.white),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<_ChartData, int>>[
                      // Main series
                      SplineSeries<_ChartData, int>(
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.index,
                        yValueMapper: (_ChartData data, _) => data.value,
                        name: chartLabel,
                        splineType: SplineType.natural,
                        color: const Color(0xFFD8A42D),
                        width: 2,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      // Highlight the current shot in red
                      SplineSeries<_ChartData, int>(
                        dataSource: [chartData[currentIndex]],
                        xValueMapper: (_ChartData data, _) => data.index,
                        yValueMapper: (_ChartData data, _) => data.value,
                        splineType: SplineType.natural,
                        color: Colors.red,
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

              // 4) Shot navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Colors.white),
                    onPressed: () => _changeShotIndex(-1),
                  ),
                  Text(
                    'Shot ${currentIndex + 1}',
                    style: GoogleFonts.tomorrow(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: Colors.white),
                    onPressed: () => _changeShotIndex(1),
                  ),
                ],
              ),

              // 5) Metrics for the current shot in a smaller 2x3 grid with info pop-ups
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  // childAspectRatio > 1 => boxes are wider than tall
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildShotMetricCard('Wrist Speed', swings[currentIndex]['wrist_speed']),
                    _buildShotMetricCard('Club Head Speed', swings[currentIndex]['club_head_speed']),
                    _buildShotMetricCard('Hip Rotation', swings[currentIndex]['hip_rotation']),
                    _buildShotMetricCard('Start/End Rotation', swings[currentIndex]['start_end_rotation']),
                    _buildShotMetricCard('Hip to Wrist Lag', swings[currentIndex]['hip_wrist_lag']),
                    _buildShotMetricCard('Back Posture', swings[currentIndex]['back_posture']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Metric selection button
  Widget _buildMetricButton(BuildContext context, String label, String metricKey) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (selectedMetric == metricKey) ? const Color(0xFFD8A42D) : Colors.grey[800],
        foregroundColor: (selectedMetric == metricKey) ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () {
        setState(() {
          selectedMetric = metricKey;
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

  /// Single card for each shot metric with an info icon for the pop-up
  Widget _buildShotMetricCard(String label, dynamic rawValue) {
    final String displayValue = (rawValue == null)
        ? 'N/A'
        : (rawValue is num)
            ? rawValue.toStringAsFixed(2)
            : rawValue.toString();

    // Get the description (if any) from the map
    final String description = metricDescriptions[label] ?? 'No description provided.';

    return Container(
      padding: const EdgeInsets.all(12), // smaller padding
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Info Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.tomorrow(
                    color: Colors.white70,
                    fontSize: 14, // smaller than before
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _displayInfoPopup(context, label, description),
                child: const Icon(Icons.info_outline, color: Colors.white70, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Value
          Text(
            displayValue,
            style: GoogleFonts.tomorrow(
              color: Colors.white,
              fontSize: 18, // smaller than before
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Info popup function (adapted from your existing code)
  void _displayInfoPopup(BuildContext context, String metric, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            metric,
            style: GoogleFonts.tomorrow(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            description,
            style: GoogleFonts.tomorrow(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.tomorrow(color: Colors.orangeAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Data model for the chart
class _ChartData {
  final int index;
  final double value;
  _ChartData(this.index, this.value);
}