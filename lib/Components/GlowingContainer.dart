import 'package:flutter/material.dart';

class GlowingContainer extends StatefulWidget {
  final Widget child;
  
  const GlowingContainer({super.key, required this.child});

  @override
  State<GlowingContainer> createState() => _GlowingContainerState();
}

class _GlowingContainerState extends State<GlowingContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> _gradientColors = [
    const Color(0xFFDD7CA9).withOpacity(0.5),  // Your theme pink
    const Color(0xFF2C2C2C).withOpacity(0.5),  // Dark gray
    const Color(0xFF1A1A1A).withOpacity(0.5),  // Darker gray
    const Color(0xFFDD7CA9).withOpacity(0.5),  // Your theme pink
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(2),  // Border width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              colors: _gradientColors,
              stops: const [0.0, 0.3, 0.7, 1.0],
              begin: AlignmentDirectional(-1 + (2 * _animation.value), 0),
              end: AlignmentDirectional(1 - (2 * _animation.value), 0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),  // Your dark background
              borderRadius: BorderRadius.circular(100),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}