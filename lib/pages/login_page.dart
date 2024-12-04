import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                const SizedBox(height: 50),
                
                // Extropian Header Text
                Image.asset(
                  'lib/images/logo_white_no_brain.png',
                  height: 200,
                ),
                const SizedBox(height: 20),

                // Extropian Header Text
                Image.asset(
                  'lib/images/extropian_brain.png',
                  height: 100,
                ),
                const SizedBox(height: 20),

                // Welcome Back text
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Username text field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Password text field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign in button
                ElevatedButton(
                  onPressed: () {
                    // Add sign-in functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Color(0xFFD8A42D)),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Ensure the text color is white for contrast
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // "Or continue with" Text
                const Text(
                  "or continue with",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Sign-In Button
                    GestureDetector(
                      onTap: () {
                        // Add Google sign-in functionality
                      },
                      child: Image.asset(
                        'lib/images/google_icon.png', 
                        height: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // "Need an account? Sign up" text
                TextButton(
                  onPressed: () {
                    // Add navigation to sign up page here
                  },
                  child: const Text(
                    "Need an account? Sign up",
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
