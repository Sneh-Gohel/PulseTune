// splash_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'package:plusetune/Screens/HomeScreen.dart';
import 'LoginScreen.dart'; // Import your LoginScreen
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
      Future.delayed(const Duration(milliseconds: 1000), () async {
        // Use the reusable transition

        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_id.txt');
        bool fileExists = file.existsSync();

        if (fileExists) {
          String fileContent = await file.readAsString();
          List<String> splitStrings = fileContent.split(" ");
          String email = splitStrings[0];
          String password = splitStrings[1];

          try {
            final UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );

            if (userCredential.user != null) {
              // Navigate to HomeScreen and clear the navigation stack

              Navigator.of(context).pushAndRemoveUntil(
                ScreenChanger.slideUpTransition(const HomeScreen()),
                (route) => false,
              );
            } else {
              print("Getting errors to fetch the details");
              Navigator.of(context).pushReplacement(
                ScreenChanger.slideUpTransition(const LoginScreen()),
              );
            }
          } catch (e) {
            print("Incorrect credentials");
            if (e.toString().contains("auth credential is incorrect")) {
              Navigator.of(context).pushReplacement(
                ScreenChanger.slideUpTransition(const LoginScreen()),
              );
            }
          }
        } else {
          print("File doesn't exists");
          Navigator.of(context).pushReplacement(
            ScreenChanger.slideUpTransition(const LoginScreen()),
          );
        }
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
