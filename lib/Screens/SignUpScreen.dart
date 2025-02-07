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
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

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
        child: Padding(
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
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your full name' : null,
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
                        if (value!.isEmpty)
                          return 'Please enter your mobile number';
                        if (value.length != 10) return 'Invalid mobile number';
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
                        if (value!.isEmpty) return 'Please enter your email';
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
                      final button = flightDirection == HeroFlightDirection.push
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            ScreenChanger.slideUpTransition(
                              OTPVerificationScreen(
                                email: _emailController.text,
                                userData: {
                                  'name': _nameController.text,
                                  'dob': _dobController.text,
                                  'mobile': _mobileController.text,
                                  'email': _emailController.text,
                                },
                              ),
                            ),
                          );
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
