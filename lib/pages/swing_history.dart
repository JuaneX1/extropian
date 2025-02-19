import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:extropian/pages/swing_history_session.dart';

class SwingHistory extends StatefulWidget {
  const SwingHistory({super.key});

  @override
  State<SwingHistory> createState() => _SwingHistoryState();
}

class _SwingHistoryState extends State<SwingHistory> {
  // Currently not having any clubs selected at first
  String _selectedAbbreviation = ''; // Default selected club abbreviation
  bool _showClubSessions = false;

  // Mapping of abbreviations to full club names
  final Map<String, String> clubMap = {
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
    '60°': '60 Degree',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.tomorrow(color: Colors.white),
        ),
        backgroundColor: Colors.black, // AppBar background color
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: Container(
        color: Colors.black, // Screen background color
        child: Column(
          children: [
            // Club head selection buttons row
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: clubMap.keys.map((abbreviation) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(
                          abbreviation,
                          style: GoogleFonts.tomorrow(
                            color: _selectedAbbreviation == abbreviation ? Colors.black : Colors.white,
                          ),
                        ),
                        selected: _selectedAbbreviation == abbreviation,
                        selectedColor: const Color(0xFFD8A42D), // Highlighted color
                        backgroundColor: Colors.grey[800], // Default background
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedAbbreviation = abbreviation;
                            _showClubSessions = true;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            Expanded(
              child: _showClubSessions
                  ? ClubSessionsScreen(
                      // Pass a unique Key to ensure rebuilding
                      key: ValueKey(_selectedAbbreviation),
                      clubName: clubMap[_selectedAbbreviation]!,
                    )
                    
                  : Center(
                      child: Text(
                        'No club selected.',
                        style: GoogleFonts.tomorrow(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubSessionsScreen extends StatefulWidget {
  final String clubName;

  const ClubSessionsScreen({super.key, required this.clubName});

  @override
  State<ClubSessionsScreen> createState() => _ClubSessionsScreenState();
}

class _ClubSessionsScreenState extends State<ClubSessionsScreen> {
  // Map metric keys to nicer labels
  final Map<String, String> metricLabels = {
    'wrist_speed': 'Wrist Speed',
    'hip_rotation': 'Hip Rotation',
    'club_head_speed': 'Club Head Speed',
  };

  String selectedMetric = 'wrist_speed'; // Default to wrist speed
  List<_ChartData> chartData = [];
  List<Map<String, dynamic>> swings = [];
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllSwings();
  }

  Future<void> _fetchAllSwings() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final sessionDocs = await firestore
        .collection('users_swings')
        .doc(user.uid)
        .collection(widget.clubName)
        .get();

    List<Map<String, dynamic>> fetchedSessions = [];
    List<Map<String, dynamic>> fetchedSwings = [];

    for (var session in sessionDocs.docs) {
      final sessionSwings = await session.reference.collection('swings').get();
      fetchedSessions.add({
        'date': session.id,
        'numShots': sessionSwings.docs.length,
      });
      for (var swing in sessionSwings.docs) {
        fetchedSwings.add(swing.data());
      }
    }

    setState(() {
      sessions = fetchedSessions;
      swings = fetchedSwings;
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

  @override
  Widget build(BuildContext context) {
    final String yAxisLabel = metricLabels[selectedMetric] ?? selectedMetric;

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Metric Selection Buttons
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
            // Graph
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
                      text: yAxisLabel,
                      textStyle: GoogleFonts.tomorrow(color: Colors.white),
                    ),
                    labelStyle: GoogleFonts.tomorrow(color: Colors.white),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_ChartData, int>>[
                    // Use a SplineSeries to get rounded/curved edges
                    SplineSeries<_ChartData, int>(
                      dataSource: chartData,
                      xValueMapper: (_ChartData data, _) => data.index,
                      yValueMapper: (_ChartData data, _) => data.value,
                      name: yAxisLabel,
                      markerSettings: const MarkerSettings(isVisible: true),
                      splineType: SplineType.natural, // Gives smoother curves
                      color: const Color(0xFFD8A42D),
                      width: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Sessions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionSwingsScreen(
                            clubName: widget.clubName,
                            date: session['date'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${session['date']} (${session['numShots']} shots)',
                            style: GoogleFonts.tomorrow(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Tap to view swings',
                            style: GoogleFonts.tomorrow(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricButton(BuildContext context, String label, String metric) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedMetric == metric ? const Color(0xFFD8A42D) : Colors.grey[800],
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
}

class _ChartData {
  final int index;
  final double value;
  _ChartData({required this.index, required this.value});
}