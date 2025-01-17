import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text; // Add a text parameter for the button label

  const MyButton({
    super.key,
    required this.onTap,
    required this.text, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color(0xFFD8A42D),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text, // Use the custom text here
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold, // Bold text
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}