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

  // Function to update user info in Firestore
  Future<void> _updateUserInfo(String field, num currentValue, String suffix) async {
    TextEditingController controller = TextEditingController(text: currentValue == 0 ? '' : currentValue.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field', style: GoogleFonts.tomorrow(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter new value",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(suffix, style: GoogleFonts.tomorrow(fontSize: 16)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  num? newValue = num.tryParse(controller.text);
                  if (newValue != null) {
                    await _firestore.collection('users').doc(_user?.uid).update({field: newValue});
                    setState(() {});
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Convert inches to feet and inches format (e.g., 72 → 6'0")
  String formatHeight(num inches) {
    if (inches == 0) return "No data";
    int feet = (inches / 12).floor();
    int remainingInches = (inches % 12).round();
    return "$feet'$remainingInches\"";
  }

  // Display "No data" if value is 0
  String formatValue(num value, String suffix) {
    return value == 0 ? "No data" : "$value $suffix";
  }

  // Editable Profile Stats Row with Pencil Icon
  Widget _buildEditableProfileStatRow(String label, num value, String field, String suffix, {bool isHeight = false}) {
    String displayValue = isHeight ? formatHeight(value) : formatValue(value, suffix);

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
        Row(
          children: [
            Text(
              displayValue,
              style: GoogleFonts.tomorrow(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _updateUserInfo(field, value, suffix),
              child: const Icon(Icons.edit, color: Colors.orangeAccent, size: 18),
            ),
          ],
        ),
      ],
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

          // Extract user info from Firestore
          final String userName = userData['name'] ?? 'Guest';
          final String userEmail = userData['email'] ?? 'No Email Provided';
          final int age = userData['age'] ?? 0;
          final double height = (userData['height'] ?? 0).toDouble();
          final double weight = (userData['weight'] ?? 0).toDouble();
          final double bodyFat = (userData['body_fat'] ?? 0).toDouble();
          final double bmi = (userData['bmi'] ?? 0).toDouble();

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

                  // User Stats with Editable Fields
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
                        _buildEditableProfileStatRow('Age', age, 'age', 'years'),
                        const Divider(color: Colors.grey),
                        _buildEditableProfileStatRow('Height', height, 'height', 'in', isHeight: true),
                        const Divider(color: Colors.grey),
                        _buildEditableProfileStatRow('Weight', weight, 'weight', 'lbs'),
                        const Divider(color: Colors.grey),
                        _buildEditableProfileStatRow('Body Fat', bodyFat, 'body_fat', '%'),
                        const Divider(color: Colors.grey),
                        _buildEditableProfileStatRow('BMI', bmi, 'bmi', ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

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
}
