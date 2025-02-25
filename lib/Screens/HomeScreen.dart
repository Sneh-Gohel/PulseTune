// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plusetune/Components/BigBoxes.dart';
import 'package:plusetune/Components/RowTiles.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'package:plusetune/Components/SuffleBox.dart';
import 'package:plusetune/Screens/HeartBeatAnalizingScreen.dart';
import 'package:plusetune/Screens/InfinityPlayerScreen.dart';
import 'package:plusetune/Screens/MusicGenerationScreen.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isLoading = true; // Add loading state
  final List<String> _imagePaths = [
    "assets/photos/hip-hop.jpg",
    "assets/photos/bass.jpg",
    "assets/photos/sleep.jpg",
    "assets/photos/study.jpeg",
    "assets/photos/nature.jpg",
    "assets/photos/yoga.jpg",
    "assets/photos/nature.jpg",
    "assets/photos/beauty.jpg",
    "assets/photos/waterfall.jpg",
    "assets/photos/small_waterfall.jpg",
    "assets/photos/drums.jpg",
    "assets/photos/flute.jpg",
    "assets/photos/guitar.jpg",
    "assets/photos/piano.jpeg",
    "assets/photos/classical.jpg",
    "assets/photos/disco.jpg",
    "assets/photos/pop.jpg",
    "assets/photos/jazz.png",
    "assets/photos/rock.jpg",
  ];

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
      duration: const Duration(seconds: 2),
    )..repeat();

    // Preload all images
    _preloadImages();
  }

  // Preload all images
  void _preloadImages() async {
    final List<Future<void>> futures = [];
    for (final path in _imagePaths) {
      final image = AssetImage(path);
      final completer = Completer<void>();
      image.resolve(const ImageConfiguration()).addListener(
            ImageStreamListener(
              (image, synchronousCall) {
                completer.complete();
              },
              onError: (exception, stackTrace) {
                completer.complete();
              },
            ),
          );
      futures.add(completer.future);
    }

    // Wait for all images to load
    await Future.wait(futures);

    // Hide loading screen
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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

  // Skeleton loading widget for horizontal lists
  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 20,
                  color: Colors.grey[800],
                ),
              ],
            ),
          );
        }),
      ),
    );
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
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _greetingMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                          style: TextStyle(color: Colors.white, fontSize: 20),
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
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      ScreenChanger.slideUpTransition(
                        InfinityPlayerScreen(isHeartbeatMusic: true,url: "",message: "",),
                      ),
                    );
                  },
                  child: Padding(
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
                              height: 124, // 150 + 4px border
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
                        Hero(
                          tag: "_heartbeat",
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 120,
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
                                    child: Center(
                                      child: Lottie.asset(
                                        'assets/lotties/heart_beat.json',
                                        fit: BoxFit.cover,
                                        repeat: true,
                                        controller: _lottieController,
                                        height: 80,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color.fromARGB(255, 226, 104, 104)
                                        ],
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
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
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
                        )
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
                        fontWeight: FontWeight.bold),
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
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      ScreenChanger.slideUpTransition(
                        const MusicGenerationScreen(),
                      ),
                    );
                  },
                  child: Padding(
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
                              height: 124, // 150 + 4px border
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
                          height: 120,
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
                                  child: Center(
                                    child: Lottie.asset(
                                      'assets/lotties/music_gen_home.json',
                                      fit: BoxFit.cover,
                                      repeat: true,
                                      height: 130,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
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
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Top Calm Listenings",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    height: 200,
                    child: _isLoading
                        ? _buildSkeletonLoading() // Show skeleton loading
                        : ListView(
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
                              SuffleBox(),
                              const SizedBox(width: 20),
                            ],
                          ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Best In Instrumental",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    height: 200,
                    child: _isLoading
                        ? _buildSkeletonLoading() // Show skeleton loading
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/drums.jpg",
                                title: "Drums",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/flute.jpg",
                                title: "Flute",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/guitar.jpg",
                                title: "Guitar",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/piano.jpeg",
                                title: "Piano",
                              ),
                              SuffleBox(),
                              const SizedBox(width: 20),
                            ],
                          ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Recommended to you 💗",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    height: 200,
                    child: _isLoading
                        ? _buildSkeletonLoading() // Show skeleton loading
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/classical.jpg",
                                title: "Classical",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/disco.jpg",
                                title: "Disco",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/pop.jpg",
                                title: "Pop",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/jazz.png",
                                title: "Jazz",
                              ),
                              const SizedBox(width: 20),
                              BigBoxes(
                                screenWidth: screenWidth,
                                image: "assets/photos/rock.jpg",
                                title: "Rock",
                              ),
                              const SizedBox(width: 20),
                              SuffleBox(),
                              const SizedBox(width: 20),
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

  Alignment _getGradientAlignment(double value) {
    final angle = value * 4; // 0-4 for full rotation
    if (angle < 1) return Alignment(-1 + 2 * angle, -1); // Left to Top
    if (angle < 2) return Alignment(1, -1 + 2 * (angle - 1)); // Top to Right
    if (angle < 3) return Alignment(1 - 2 * (angle - 2), 1); // Right to Bottom
    return Alignment(-1, 1 - 2 * (angle - 3)); // Bottom to Left
  }
}
