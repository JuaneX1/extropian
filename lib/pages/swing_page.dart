import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// import 'package:google_fonts/google_fonts.dart';

class SwingPage extends StatefulWidget {
  const SwingPage({super.key});

  @override
  State<SwingPage> createState() => _SwingPageState();
}

class _SwingPageState extends State<SwingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // Selected golf club for the dropdown
  String? _selectedClub;

  // List of golf clubs
  final List<String> _golfClubs = [
    'Driver',
    '3 Wood',
    '3 Iron',
    '4 Iron',
    '5 Iron',
    '6 Iron',
    '7 Iron',
    '8 Iron',
    '9 Iron',
    'Pitching Wedge',
    'Sand Wedge',
    '60 Degree'
  ];

  @override
  void initState() {
    super.initState();
  }

  // Function to save the selected club, create a date collection, and add swings
  Future<void> _saveSelectedClub() async {
    if (_selectedClub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a golf club')),
      );
      return;
    }

    try {
      // Get the current date and time
      String currentDateTime = DateFormat('MMMM d, yyyy h:mm a').format(DateTime.now());

      // Reference to the new collection for the selected club and current date
      var dateDocRef = _firestore
          .collection('users_swings') // Main collection
          .doc(_user?.uid) // Document for the specific user
          .collection(_selectedClub!) // Collection named after the selected club
          .doc(currentDateTime);

      // Generate random swings data
      Random random = Random();
      int swingCount = random.nextInt(10) + 1; // Random number between 1 and 10

      // Create total swings doc
      await dateDocRef.set({'totalSwings': swingCount});

      for (int i = 1; i <= swingCount; i++) {
        // Add a swing document to the swings collection with custom ID
        await dateDocRef.collection('swings').doc(i.toString()).set({
          'wrist_speed': random.nextDouble() * 150, // Random speed between 0 and 150
          'club_head_speed': random.nextDouble() * 150, 
          'hip_rotation': random.nextDouble() * 150,
          'start_end_rotation': random.nextDouble() * 150,
          'hip_wrist_lag': random.nextDouble() * 150,
          'back_posture': random.nextDouble() * 150,
          'date': FieldValue.serverTimestamp(), // Current timestamp
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$swingCount swings added under "$_selectedClub/$currentDateTime"!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create swings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swing Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select a Golf Club',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Choose a club'),
              value: _selectedClub,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClub = newValue;
                });
              },
              items: _golfClubs.map<DropdownMenuItem<String>>((String club) {
                return DropdownMenuItem<String>(
                  value: club,
                  child: Text(club),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_selectedClub != null)
              Text(
                'You selected: $_selectedClub',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveSelectedClub,
              child: const Text('Start Swing'),
            ),
            const SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}
