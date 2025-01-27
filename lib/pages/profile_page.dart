import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extropian/auth/auth_service.dart';
import 'package:extropian/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // Function to sign out the user
  void _signOut() async {
    await _auth.signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
          'Profile',
          style: GoogleFonts.tomorrow(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
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
          final userEmail = userData['email'] ?? 'No Email Provided';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Picture
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('lib/images/extropian_brain.png'),
                  ),
                  const SizedBox(height: 20),

                  // Name and Email
                  Text(
                    userName,
                    style: GoogleFonts.tomorrow(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: GoogleFonts.tomorrow(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileStatRow('Age', '28 years'),
                        const Divider(color: Colors.grey),
                        _buildProfileStatRow('Height', '5\'9" (175 cm)'),
                        const Divider(color: Colors.grey),
                        _buildProfileStatRow('Weight', '150 lbs (68 kg)'),
                        const Divider(color: Colors.grey),
                        _buildProfileStatRow('Body Fat', '18%'),
                        const Divider(color: Colors.grey),
                        _buildProfileStatRow('BMI', '22.1 (Normal)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Health Metrics Section
                  Text(
                    'Health Metrics',
                    style: GoogleFonts.tomorrow(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildHealthMetricCard('Resting Heart Rate', '57 bpm', 'Excellent'),
                  const SizedBox(height: 10),
                  _buildHealthMetricCard('HRV', '42 ms', 'Good'),
                  const SizedBox(height: 10),
                  _buildHealthMetricCard('Steps Today', '5,820 steps', 'Keep Going!'),
                  const SizedBox(height: 10),
                  _buildHealthMetricCard('Calories Burned', '1,240 kcal', 'On Track'),
                  const SizedBox(height: 40),

                  // Logout Button
                  ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.tomorrow(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper Widget for Profile Stats
  Widget _buildProfileStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.tomorrow(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.tomorrow(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper Widget for Health Metric Cards
  Widget _buildHealthMetricCard(String title, String value, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.tomorrow(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.tomorrow(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            status,
            style: GoogleFonts.tomorrow(
              color: status == 'Excellent'
                  ? Colors.greenAccent
                  : (status == 'Good' ? Colors.orangeAccent : Colors.redAccent),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
