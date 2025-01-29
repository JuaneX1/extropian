import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extropian/auth/auth_service.dart';
import 'package:extropian/pages/home_page.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  // AuthService instance
  final _auth = AuthService();

  // Controllers for text fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Register function
  Future<void> _signup(BuildContext context) async {
    try {
      // Check if passwords match
      if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      // Create user with email and password
      final user = await _auth.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        final uid = user.uid;

        // Save the user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'age': 0,
          'height': 0,
          'weight': 0,
          'body_fat': 0,
          'bmi': 0,
          'createdAt': DateTime.now(),
        });

        // Send email verification
        await user.sendEmailVerification();

        log("User created and data saved successfully");

        // Inform the user to verify their email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully created! Please verify your email.')),
        );

        // Navigate to login page
        goToLogin(context);
      }
    } catch (e) {
      log("Signup error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    }
  }

  // Navigation Helper Methods
  void goToLogin(BuildContext context) {
    Navigator.pop(context); // Go back to the previous screen (LoginPage)
  }

  void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Extropian Header Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/images/extropian_whitenobrain.png',
                        height: 200,
                      ),
                      Image.asset(
                        'lib/images/extropian_brain.png',
                        height: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name text field
                  MyTextField(
                    controller: nameController,
                    hintText: "Name",
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),

                  // Email text field
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),

                  // Password text field
                  MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password text field
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                  ),

                  // Register button
                  const SizedBox(height: 50),
                  MyButton(
                    onTap: () => _signup(context), // Call _signup with context
                    text: "Register",
                  ),

                  // "Already have an account? Login here" text
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => goToLogin(context), // Navigate to LoginPage
                        child: const Text(
                          'Login here',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
