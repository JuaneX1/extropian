import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  // Text editing controller
  final emailController = TextEditingController();

  // Method to send a password reset email
  void sendPasswordReset() {
    print("Password reset link sent to: ${emailController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'lib/images/logo_white_no_brain.png',
                      height: 200,
                    ),

                    // Extropian Brain Logo
                    Image.asset(
                      'lib/images/extropian_brain.png',
                      height: 100,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Reset Password title
                const Text(
                  'Forgot Your Password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),

                // Reset Password subtitle
                const Text(
                  'Enter your email to reset your password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),

                // Email text field
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                // Reset Password button
                MyButton(
                  onTap: sendPasswordReset,
                  text: "Reset Password", 
                ),

                const SizedBox(height: 20),

                // Back to Login button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}