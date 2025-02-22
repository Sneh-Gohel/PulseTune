// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'package:plusetune/Screens/OTPVerificationScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;
  bool loadingScreen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFDD7CA9),
              onPrimary: Colors.white,
              surface: Color(0xFF121111),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121111),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<bool> sendOTPEmail(String recipientEmail, String otp) async {
    setState(() {
      loadingScreen = true;
    });

    String username = "gohelsneh21@gmail.com";
    String password = "qiza fvct ibeu rijr";

    // SMTP Server Details
    final smtpServer = gmail(username, password);

    // Email body with a simple message or HTML content
    final message = Message()
      ..from = Address(username, 'PluseTune')
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Verification Code'
      // Provide a plain text version
      ..text = 'Your OTP code is: $otp'
      // And provide the HTML version as well
      ..html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>PluseTune Account Verification</title>
    </head>
    <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background: linear-gradient(to bottom right, #DBD897, #DD7CA9); color: #000; text-align: center; padding: 20px;">
      <div style="max-width: 600px; margin: auto; background-color: #fff; border-radius: 10px; box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1); padding: 20px;">
        <!-- Logo -->

    
        <!-- Heading -->
        <h1 style="font-size: 24px; color: #333;">OTP Verification</h1>
    
        <!-- Message -->
        <p style="font-size: 16px; color: #555;">Your verification OTP is:</p>
    
        <!-- OTP -->
        <div style="font-size: 32px; font-weight: bold; color: #DD7CA9; margin-top: 10px;">$otp</div>
    
        <!-- Footer -->
        <p style="font-size: 12px; color: #888; margin-top: 20px;">If you did not request this OTP, please ignore this email.</p>
      </div>
    </body>
    </html>
  """;

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent successfully!")),
      );
      return true;
    } catch (e) {
      if (e.toString().contains('User not found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Can't find the email address, please check!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP: $e")),
        );
      }
      print("Error sending email: $e");
      return false;
    } finally {
      setState(() {
        loadingScreen = false;
      });
    }
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121111),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Animated Logo
                    SlideTransition(
                      position: _offsetAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                            height: 215,
                            width: 275,
                            margin: const EdgeInsets.only(top: 00, bottom: 10),
                            child: Hero(
                              tag: "logo",
                              child: Image.asset(
                                "assets/photos/logo.png",
                                fit: BoxFit.contain,
                              ),
                            )),
                      ),
                    ),

                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: const Text(
                        'Create your account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Full Name Field
                    SlideTransition(
                      position: _offsetAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.white70),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your full name'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Date of Birth Field
                    SlideTransition(
                      position: _offsetAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          controller: _dobController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.white70),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) => value!.isEmpty
                              ? 'Please select your date of birth'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Mobile Number Field
                    SlideTransition(
                      position: _offsetAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          controller: _mobileController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            prefixIcon:
                                const Icon(Icons.phone, color: Colors.white70),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (value.length != 10) {
                              return 'Invalid mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    SlideTransition(
                      position: _offsetAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.white70),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Invalid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SlideTransition(
                      position: _offsetAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            prefixIcon: const Icon(Icons.password,
                                color: Colors.white70),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the password';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Button
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: Hero(
                        tag: "button",
                        flightShuttleBuilder: (flightContext, animation,
                            flightDirection, fromHeroContext, toHeroContext) {
                          final button =
                              flightDirection == HeroFlightDirection.push
                                  ? toHeroContext.widget
                                  : fromHeroContext.widget;

                          return Material(
                            color: Colors.transparent,
                            child: Transform.scale(
                              scale: Tween<double>(begin: 0.95, end: 1.0)
                                  .evaluate(animation),
                              child: button,
                            ),
                          );
                        },
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String otp = generateOTP();
                              if (await sendOTPEmail(
                                  _emailController.text, otp)) {
                                Navigator.push(
                                  context,
                                  ScreenChanger.slideUpTransition(
                                    OTPVerificationScreen(
                                      userData: {
                                        'name': _nameController.text,
                                        'dob': _dobController.text,
                                        'mobile': _mobileController.text,
                                        'email': _emailController.text,
                                        'password': _passwordController.text,
                                        'otp': otp,
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFFDD7CA9),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Existing Account Link
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _offsetAnimation,
                        child: Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text.rich(
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: 'Log In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loadingScreen
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFFDD7CA9)),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 30),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFDD7CA9)],
                            ).createShader(bounds),
                            child: const Text(
                              'Registering...',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Getting things ready for you...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white54),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
