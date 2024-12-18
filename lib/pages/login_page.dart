import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_frame.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Controllers for text fields
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign in function
  void signUserIn(){}

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
                      Text( 'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Sign in button
                const SizedBox(height: 50),
                MyButton(onTap: signUserIn),

                // "Or continue with" Text
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 0.5,
                        ),
                      ),
                  
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.white),
                          ),
                      ),
                  
                      const Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Google Logo
                const SizedBox(height: 20),
                const SquareFrame(imagePath: 'lib/images/google_icon.png'),
                const SizedBox(height: 25),
                // "Need an account? Sign up" text
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member? ',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Register now',
                      style: TextStyle(color: Colors.blue),
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
