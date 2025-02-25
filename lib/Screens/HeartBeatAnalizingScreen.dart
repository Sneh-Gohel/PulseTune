// ignore_for_file: file_names

import 'package:flutter/material.dart';

class HeartBeatAnalizingScreen extends StatefulWidget {
  const HeartBeatAnalizingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HeartBeatAnalizingScreen();
}

class _HeartBeatAnalizingScreen extends State<HeartBeatAnalizingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sync Your Music with 💗',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
