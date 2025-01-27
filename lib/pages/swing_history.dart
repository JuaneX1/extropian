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
  String selectedMetric = 'wrist_speed'; // Default to speed
  List<_ChartData> chartData = [];
  List<Map<String, dynamic>> swings = [];
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
    final sessions = await firestore
        .collection('users_swings')
        .doc(user.uid)
        .collection(widget.clubName)
        .get();

    List<Map<String, dynamic>> fetchedSwings = [];

    for (var session in sessions.docs) {
      final sessionSwings = await session.reference.collection('swings').get();
      for (var swing in sessionSwings.docs) {
        fetchedSwings.add(swing.data());
      }
    }

    setState(() {
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: Text(
          '${widget.clubName} Sessions',
          style: GoogleFonts.tomorrow(color: Colors.white),
        ),
        backgroundColor: Colors.black, // AppBar background color
      ),
      body: Container(
        color: Colors.black, // Screen background color
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Buttons for metric selection
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
                    // Display average metric
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total Average ${selectedMetric.capitalize()}: ${_calculateAverage().toStringAsFixed(2)}',
                        style: GoogleFonts.tomorrow(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Enlarged chart area
                    SizedBox(
                      height: 400, // Larger height for the chart
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
                          ],
                        ),
                      ),
                    ),
                    // Sessions section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Sessions',
                        style: GoogleFonts.tomorrow(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Scrollable session list
                    SizedBox(
                      height: 400, // Fixed height for the sessions list
                      child: FutureBuilder<List<QueryDocumentSnapshot>>(
                        future: _fetchSessions(),
                        builder: (context, sessionSnapshot) {
                          if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (sessionSnapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${sessionSnapshot.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          final sessions = sessionSnapshot.data ?? [];
                          if (sessions.isEmpty) {
                            return const Center(
                              child: Text(
                                'No sessions found for this club.',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[sessions.length - 1 - index];
                              final date = session.id;
                              return ListTile(
                                title: Text(
                                  date,
                                  style: GoogleFonts.tomorrow(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SessionSwingsScreen(
                                        clubName: widget.clubName,
                                        date: date,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
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

  double _calculateAverage() {
    if (chartData.isEmpty) return 0.0;
    return chartData.map((e) => e.value).reduce((a, b) => a + b) / chartData.length;
  }

  Future<List<QueryDocumentSnapshot>> _fetchSessions() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final sessions = await firestore
        .collection('users_swings')
        .doc(user.uid)
        .collection(widget.clubName)
        .get();

    return sessions.docs;
  }
}


class _ChartData {
  final int index;
  final double value;

  _ChartData({required this.index, required this.value});
}
