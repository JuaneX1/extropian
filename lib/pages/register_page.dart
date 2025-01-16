import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  // Controllers for text fields
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Register function
  void registerUser() {
    // BACKEND TEAM: Add your registration API call here
    // Example: Call your backend service to create a new user
    // Use the following data from text controllers:
    // usernameController.text, emailController.text,
    // passwordController.text, confirmPasswordController.text
    
    print("Register triggered");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView( // Add scrolling behavior
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
                  MyTextField(controller: usernameController, hintText: "Username", obscureText: false),
                  const SizedBox(height: 15),

                  // Email text field
                  MyTextField(controller: emailController, hintText: "Email", obscureText: false),
                  const SizedBox(height: 15),

                  // Password text field
                  MyTextField(controller: passwordController, hintText: "Password", obscureText: true),
                  const SizedBox(height: 15),

                  // Confirm Password text field
                  MyTextField(controller: confirmPasswordController, hintText: "Confirm Password", obscureText: true),

                  // Register button
                  const SizedBox(height: 50),
                  MyButton(onTap: registerUser),

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
                        onTap: () {
                          Navigator.pop(context);
                        },
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