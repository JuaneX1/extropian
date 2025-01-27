import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:extropian/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:extropian/auth/auth_service.dart';
import 'package:extropian/auth/register_page.dart';
import 'package:extropian/auth/forgot_password_page.dart'; 
import 'package:extropian/pages/home_page.dart';
import 'package:extropian/components/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Set the background color to black
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView( // Add SingleChildScrollView here
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
                  const SizedBox(height: 25), // space between images

                  // Second image (below Extropian logo)
                  Image.asset(
                    'lib/images/extropian_brain.png', // path to your second image
                    height: 150,
                  ),

                  const SizedBox(height: 50),

                  // Redefine What’s Possible text
                  Text(
                    'Redefine What’s Possible',
                    style: GoogleFonts.tomorrow(
                      textStyle: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Username textfield
                  MyTextField(
                    controller: _email,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // Password textfield
                  MyTextField(
                    controller: _password,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // Forgot Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => goToForgotPassword(context), // Navigate to Forgot Password
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.tomorrow(
                              textStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  MyButton(
                    onTap: _login, // Call signUserIn with context
                    text: "Sign In", // Pass the text for the button
                  ),

                  const SizedBox(height: 50),

                  // Not a member? Register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: GoogleFonts.tomorrow(
                          textStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => goToRegister(context),
                        child: Text(
                          'Register now',
                          style: GoogleFonts.tomorrow(
                            textStyle: const TextStyle(
                              color: Color(0xFFD8A42D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  goToRegister(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  HomePage()),
      );

  goToForgotPassword(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgotPasswordPage()), // Navigate to ForgotPasswordPage
      );

  _login() async {
    final user =
        await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      log("User Logged In");
      goToHome(context);
    }
  }
}
