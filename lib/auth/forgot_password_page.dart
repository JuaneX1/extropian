import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:extropian/components/my_button.dart';
import 'package:extropian/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  // text editing controller
  final emailController = TextEditingController();

  // method to send a password reset email
  Future<void> sendPasswordReset(BuildContext context) async {
    try {
      // Get email from the text field
      final email = emailController.text.trim();

      // Check if the email field is not empty
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your email")),
        );
        return;
      }

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent! Check your inbox.")),
      );
    } catch (e) {
      // Handle errors (e.g., invalid email format, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF000000),  // Set the background color to solid black
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button at the top-left corner
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),  // White color for contrast on black
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the login page
                  },
                ),
              ),

              // Center content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 45),

                    // Extropian logo
                    Center(
                      child: Image.asset(
                        'lib/images/extropian_whitenobrain.png', // path to your logo
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Second image (below Extropian logo)
                    Image.asset(
                      'lib/images/extropian_brain.png', 
                      height: 150,
                    ),

                    const SizedBox(height: 50),

                    // Reset Password text
                    Text(
                      'Forgot Your Password?',
                      style: GoogleFonts.tomorrow(
                        textStyle: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your email to reset your password',
                      style: GoogleFonts.tomorrow(
                        textStyle: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Email textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 25),

                    // Send Reset button
                    MyButton(
                      onTap: () => sendPasswordReset(context),
                      text: "Send Reset Link",
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
}
