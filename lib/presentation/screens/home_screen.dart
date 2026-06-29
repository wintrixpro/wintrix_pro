import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Text("Wintrix Pro: Home Screen Setup Pending", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
