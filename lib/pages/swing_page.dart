import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class SwingPage extends StatefulWidget {
  @override
  _SwingPageState createState() => _SwingPageState();
}

class _SwingPageState extends State<SwingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  String? selectedClub;
  bool isPractice = true;

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
    '60Â°': '60 Degree'
  };

  Future<void> _saveSelectedClub() async {
    if (selectedClub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a golf club')),
      );
      return;
    }

    String fullClubName = clubMapping[selectedClub] ?? selectedClub!;

    try {
      String currentDateTime = DateFormat('MMMM d, yyyy h:mm a').format(DateTime.now());
      var dateDocRef = _firestore
          .collection('users_swings')
          .doc(_user?.uid)
          .collection(fullClubName)
          .doc(currentDateTime);

      Random random = Random();
      int swingCount = random.nextInt(10) + 1;

      await dateDocRef.set({'totalSwings': swingCount});

      for (int i = 1; i <= swingCount; i++) {
        await dateDocRef.collection('swings').doc(i.toString()).set({
          'wrist_speed': random.nextDouble() * 150,
          'club_head_speed': random.nextDouble() * 150,
          'hip_rotation': random.nextDouble() * 150,
          'start_end_rotation': random.nextDouble() * 150,
          'hip_wrist_lag': random.nextDouble() * 150,
          'back_posture': random.nextDouble() * 150,
          'date': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$swingCount swings added under "$fullClubName/$currentDateTime"!')),
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
        backgroundColor: Colors.black,
        title: Text('Swing Page', style: GoogleFonts.tomorrow(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('lib/images/extropian_brain.png', height: 100)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveSelectedClub,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD8A42D),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Start', style: GoogleFonts.tomorrow(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Stop', style: GoogleFonts.tomorrow(fontSize: 16)),
                ),
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text('Practice', style: GoogleFonts.tomorrow(color: isPractice ? Color(0xFFD8A42D) : Colors.grey, fontSize: 16)),
            //     Switch(
            //       value: isPractice,
            //       onChanged: (value) {
            //         setState(() {
            //           isPractice = value;
            //         });
            //       },
            //       activeColor: Color(0xFFD8A42D),
            //       inactiveThumbColor: Colors.grey,
            //     ),
            //     Text('Play', style: GoogleFonts.tomorrow(color: !isPractice ? Color(0xFFD8A42D) : Colors.grey, fontSize: 16)),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}