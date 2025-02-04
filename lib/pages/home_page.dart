import 'package:extropian/pages/profile_page.dart';
import 'package:extropian/pages/swing_page.dart';
import 'package:extropian/pages/swing_history.dart';
import 'package:extropian/pages/bluetooth_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:extropian/components/info_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Keeps track of the selected tab
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

      // Navigation based on selected index
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BluetoothPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SwingPage()),
      );
    } else if (index == 3) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SwingHistory()), 
      );
    } else if (index == 4) { 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(_user?.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userName = userData['name'] ?? 'Guest';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers the row items
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'lib/images/extropian_whitenobrain.png',
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Home,',
                    style: GoogleFonts.tomorrow(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.tomorrow(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // Bluetooth Connection and Swing History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Start your swing section
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Start your swing',
                                style: GoogleFonts.tomorrow(
                                    fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SwingPage()),
                                  );
                                },
                                icon: const Icon(Icons.sports_golf_rounded, color: Colors.white),
                                label: Text('Start Swing', style: GoogleFonts.tomorrow()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD8A42D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Swing History section
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Swing History',
                                style: GoogleFonts.tomorrow(
                                    fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SwingHistory()),
                                  );
                                },
                                icon: const Icon(Icons.golf_course_outlined, color: Colors.white),
                                label: Text('View History', style: GoogleFonts.tomorrow()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD8A42D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Health Metrics Grid
                  Expanded(
                  child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                   _buildMetricCard(context, 'RHR (Morning)', '60.8 bpm', '+ Good < 65.1', 'Resting Heart Rate measures heart beats per minute while at rest.'),
                   _buildMetricCard(context, 'HRV (Morning)', '50.0 ms', '+ Good > 38.8', 'Heart Rate Variability measures the time variation between heartbeats.'),
                   _buildMetricCard(context, 'RHR (Nighttime)', '57.5 bpm', '+ Good < 57.6', 'Resting Heart Rate during nighttime sleep.'),
                   _buildMetricCard(context, 'HRV (Nighttime)', '46.9 ms', 'Normal 43.9 to 52.2', 'Heart Rate Variability during nighttime sleep.'),
                   _buildMetricCard(context, 'Sleep Duration', '8 h 47 min', '', 'Total duration of sleep recorded during the night.'),
                   _buildMetricCard(context, 'Average HR', '57.8 bpm', '', 'Average heart rate calculated throughout the day.'),
                   _buildMetricCard(context, 'Calories Burned', '924 kcal', '', 'Estimated calories burned based on activity and heart rate.'),
                   _buildMetricCard(context, 'Total Steps', '304 steps', '', 'Total number of steps taken throughout the day.'),
                ],
              ),
            ),
                ],
              ),
            );
          },
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth),
              label: 'Bluetooth',
            ),
            BottomNavigationBarItem(
              // Custom golf ball icon for the swing page
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8A42D),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.sports_golf, color: Colors.white, size: 32),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.timeline_outlined),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMetricCard(BuildContext context, String title, String value, String status, String description) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.tomorrow(color: Colors.white70, fontSize: 16),
            ),
            GestureDetector(
              onTap: () => displayInfoPopup(context, title, description),
              child: const Icon(Icons.info_outline, color: Colors.white70, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.tomorrow(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              status,
              style: GoogleFonts.tomorrow(color: Colors.greenAccent, fontSize: 14),
            ),
          ),
      ],
    ),
  );
 }
}
