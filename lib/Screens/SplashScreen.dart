// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'LoginScreen.dart'; // Import your LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _topColorAnimation;
  var size, height, width;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Increased duration
    );

    // Logo fade animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Gradient top color animation
    _topColorAnimation = ColorTween(
      begin: const Color(0xFFDBD897), // Initial bottom color
      end: const Color(0xFFDD7CA9), // Final top color
    ).animate(_controller);

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        // Use the reusable transition
        Navigator.of(context).pushReplacement(
          ScreenChanger.slideUpTransition(const LoginScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _topColorAnimation.value!,
                  const Color(0xFFDBD897), // Fixed bottom color
                ],
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  height: 300,
                  width: 300,
                  child: ClipRRect(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Hero(
                        tag: "logo",
                        child: Image.asset(
                          "assets/photos/logo.png",
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
