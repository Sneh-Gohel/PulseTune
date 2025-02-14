import 'package:flutter/material.dart';

class SuffleBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), // Dark background
                borderRadius: BorderRadius.circular(100), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFFDD7CA9).withOpacity(0.3), // Glow effect
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(-5, 5),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2C2C2C).withOpacity(0.8),
                    const Color(0xFF1A1A1A).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  // Add your shuffle logic here
                },
                icon: const Icon(
                  Icons.shuffle,
                  size: 50, // Icon size
                  color: Color(0xFFDD7CA9), // Theme pink color
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
