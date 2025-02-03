import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Function to show the info pop-up
displayInfoPopup(BuildContext context, String metric, String description) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: Text(metric, style: GoogleFonts.tomorrow(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text(description, style: GoogleFonts.tomorrow(color: Colors.white70, fontSize: 16)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close", style: GoogleFonts.tomorrow(color: Colors.orangeAccent)),
          ),
        ],
      );
    },
  );
}

// Modify metric card to include the info button
Widget buildMetricCard(BuildContext context, String title, String value, String status, String description) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.tomorrow(color: Colors.white70, fontSize: 16),
            ),
            GestureDetector(
              onTap: () => displayInfoPopup(context, title, description),
              child: const Icon(Icons.info_outline, color: Colors.white70, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.tomorrow(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              status,
              style: GoogleFonts.tomorrow(color: Colors.greenAccent, fontSize: 14),
            ),
          ),
      ],
    ),
  );
}
