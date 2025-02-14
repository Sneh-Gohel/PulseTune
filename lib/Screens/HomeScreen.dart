import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plusetune/Components/BigBoxes.dart';
import 'package:plusetune/Components/RowTiles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  final double _scrollThreshold = 100.0;
  String _greetingMessage = "";
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _printGreeting();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust duration for speed
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  double _getAnimationFraction() {
    return (_scrollOffset / _scrollThreshold).clamp(0.0, 1.0);
  }

  void _printGreeting() {
    final DateTime now = DateTime.now();
    final int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      _greetingMessage = 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      _greetingMessage = 'Good Afternoon!';
    } else if (hour >= 17 && hour < 21) {
      _greetingMessage = 'Good Evening!';
    } else {
      _greetingMessage = 'Good Night!';
    }
    setState(() {}); // Update the UI
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 18, 17, 17),
            title: const Text(
              'Are you sure?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Do you want to exit the application?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Color(0xFFDD7CA9)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final animationFraction = _getAnimationFraction();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 18, 17, 17),
          elevation: 0,
          title: AnimatedOpacity(
            opacity: animationFraction,
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _greetingMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            AnimatedOpacity(
              opacity: animationFraction,
              duration: const Duration(milliseconds: 300),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // Add settings functionality
                },
              ),
            ),
          ],
        ),
        body: Container(
          color: const Color.fromARGB(255, 18, 17, 17),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 70),
              children: [
                AnimatedOpacity(
                  opacity: 1 - animationFraction,
                  duration: const Duration(milliseconds: 300),
                  child: Transform.translate(
                    offset: Offset(0, -50 * animationFraction),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Welcome",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            // Add settings functionality
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Infinite Listening",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Rowtiles(
                    screenWidth: screenWidth,
                    image_1: "assets/photos/hip-hop.jpg",
                    title_1: "Hip-Hop",
                    image_2: "assets/photos/bass.jpg",
                    title_2: "Bass",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Rowtiles(
                    screenWidth: screenWidth,
                    image_1: "assets/photos/sleep.jpg",
                    title_1: "Sleep",
                    image_2: "assets/photos/study.jpeg",
                    title_2: "Study",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Rowtiles(
                    screenWidth: screenWidth,
                    image_1: "assets/photos/nature.jpg",
                    title_1: "Nature",
                    image_2: "assets/photos/yoga.jpg",
                    title_2: "Yoga",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Stack(
                    children: [
                      // Glowing border
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 3),
                        curve: Curves.linear,
                        builder: (context, value, child) {
                          return Container(
                            height: 154, // 150 + 4px border
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 226, 104, 104)
                                      .withOpacity(0.3),
                                  Colors.transparent,
                                  const Color.fromARGB(255, 226, 104, 104)
                                      .withOpacity(0.3),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: _getGradientAlignment(value),
                                end: _getGradientAlignment(value + 0.5),
                              ),
                            ),
                          );
                        },
                      ),
                      // Main content
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2C2C2C).withOpacity(0.8),
                              const Color(0xFF1A1A1A).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                                child: Lottie.asset(
                                  'assets/lotties/heart_beat.json',
                                  fit: BoxFit.cover,
                                  repeat: true,
                                  controller: _lottieController,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [Colors.white, Color(0xFFDD7CA9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    "Sync your music\nto your heartbeat",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        )
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Stack(
                    children: [
                      // Glowing border
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 3),
                        curve: Curves.linear,
                        builder: (context, value, child) {
                          return Container(
                            height: 154, // 150 + 4px border
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFDD7CA9).withOpacity(0.3),
                                  Colors.transparent,
                                  const Color(0xFFDD7CA9).withOpacity(0.3),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: _getGradientAlignment(value),
                                end: _getGradientAlignment(value + 0.5),
                              ),
                            ),
                          );
                        },
                      ),
                      // Main content
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2C2C2C).withOpacity(0.8),
                              const Color(0xFF1A1A1A).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                ),
                                child: Lottie.asset(
                                  'assets/lotties/music_gen_home.json',
                                  fit: BoxFit.cover,
                                  repeat: true,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [Colors.white, Color(0xFFDD7CA9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    "Generate a music\nin your mood",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        )
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Top Calm Listenings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    height: 200, // Set appropriate height for your BigBoxes
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        BigBoxes(
                          screenWidth: screenWidth,
                          image: "assets/photos/nature.jpg",
                          title: "Nature",
                        ),
                        const SizedBox(width: 20),
                        BigBoxes(
                          screenWidth: screenWidth,
                          image: "assets/photos/beauty.jpg",
                          title: "Beauty",
                        ),
                        const SizedBox(width: 20),
                        BigBoxes(
                          screenWidth: screenWidth,
                          image: "assets/photos/waterfall.jpg",
                          title: "Waterfall",
                        ),
                        const SizedBox(width: 20),
                        BigBoxes(
                          screenWidth: screenWidth,
                          image: "assets/photos/small_waterfall.jpg",
                          title: "Calm",
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getGradientAlignment(double value) {
    final angle = value * 4; // 0-4 for full rotation
    if (angle < 1) return Alignment(-1 + 2 * angle, -1); // Left to Top
    if (angle < 2) return Alignment(1, -1 + 2 * (angle - 1)); // Top to Right
    if (angle < 3) return Alignment(1 - 2 * (angle - 2), 1); // Right to Bottom
    return Alignment(-1, 1 - 2 * (angle - 3)); // Bottom to Left
  }
}
