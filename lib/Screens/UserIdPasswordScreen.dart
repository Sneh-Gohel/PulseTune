import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UserIdPasswordScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserIdPasswordScreen({super.key, required this.userData});

  @override
  State<UserIdPasswordScreen> createState() => _UserIdPasswordScreenState();
}

class _UserIdPasswordScreenState extends State<UserIdPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121111),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            child: ListView(
              children: [
                SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Column(
                      children: [
                        Center(
                          child: Lottie.asset(
                            'assets/lotties/signup.json', // Path to your Lottie file
                            width: 200, // Adjust width as needed
                            height: 250, // Adjust height as needed
                            fit: BoxFit.fill,
                            repeat: true,
                          ),
                        ),
                        const Text(
                          'Create Credentials',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _userIdController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Choose User ID',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Create Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _completeRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Complete Registration',
                              style: TextStyle(
                                color: Color(0xFFDD7CA9),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeRegistration() {
    // Implement registration logic
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   CustomTransitions.slideUpTransition(const LoginScreen()),
    //   (route) => false,
    // );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white54),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
