import 'dart:ui';
import 'package:flutter/material.dart';

class UpdatePopup extends StatelessWidget {
  final VoidCallback onUpdatePressed;

  const UpdatePopup({Key? key, required this.onUpdatePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("⚠️ Update Required!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "To keep Wintrix Pro safe, smooth, and fair, updating to the latest patch is mandatory.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onUpdatePressed,
            child: const Text("Update Now", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
