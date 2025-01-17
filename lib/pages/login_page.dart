import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_frame.dart';
import 'register_page.dart'; // Import RegisterPage
import 'forgot_password_page.dart'; // Import ForgotPasswordPage

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Controllers for text fields
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign in function
  void signUserIn() {
    // BACKEND TEAM: Add your login API call here
    print("Sign-In triggered for: ${usernameController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                
                // Username text field
                MyTextField(controller: usernameController, hintText: "Username or email", obscureText: false),
                const SizedBox(height: 15),

                // Password text field
                MyTextField(controller: passwordController, hintText: "Password", obscureText: true),

                // Forgot Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to ForgotPasswordPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sign in button
                const SizedBox(height: 50),
                MyButton(
                  onTap: signUserIn,
                  text: "Sign In", 
                ),

                // Google Logo
                const SizedBox(height: 20),
                const SquareFrame(imagePath: 'lib/images/google_icon.png'),
                const SizedBox(height: 25),

                // "Need an account? Sign up" text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a member? ',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to RegisterPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register now',
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
    );
  }
}