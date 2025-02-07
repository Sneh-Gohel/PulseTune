import 'package:flutter/material.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'package:plusetune/Screens/SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 18, 17, 17),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Hero(
                        tag: "logo",
                        child: Image.asset(
                          "assets/photos/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                FadeTransition(
                  opacity: _opacityAnimation,
                  child: const Text(
                    'Login to your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field with Animation
                SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _inputBorder(),
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.white70),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Password Field with Animation
                SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _inputBorder(),
                        prefixIcon:
                            const Icon(Icons.lock, color: Colors.white70),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your password' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Animated Remember Me Section
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _offsetAnimation,
                    child: Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value!),
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.all(Colors.white54),
                        ),
                        const Text('Remember me',
                            style: TextStyle(color: Colors.white)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {/* Add forgot password logic */},
                          child: const Text('Forgot the password?',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Animated Login Button
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
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Log in',
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

                // Animated Social Login Divider
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white54)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or continue with',
                            style: TextStyle(color: Colors.white)),
                      ),
                      Expanded(child: Divider(color: Colors.white54)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Animated Social Icons
                SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon('assets/icons/google.png'),
                        const SizedBox(width: 25),
                        _socialIcon('assets/icons/apple.png'),
                        const SizedBox(width: 25),
                        _socialIcon('assets/icons/fb.png'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Animated Sign Up Link
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _offsetAnimation,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            ScreenChanger.slideUpTransition(
                                const SignUpScreen()),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                )
                              ]),
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

  Widget _socialIcon(String asset) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white54)),
        child: Image.asset(asset, width: 24, height: 24),
      );

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Add login logic
    }
  }
}
