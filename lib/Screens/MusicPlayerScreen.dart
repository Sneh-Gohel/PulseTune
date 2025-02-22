import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLiked = false; // Track like state
  double _currentPosition = 0;
  double _totalDuration = 1;
  final Duration _duration = const Duration(milliseconds: 440);
  bool _loadingScreen = false; // Add loading state

  // Default Colors
  var topLeft = const Color(0xFF2A2A2A); // Light Deep Charcoal
  var topRight = const Color(0xFF3A3A3A); // Light Dark Slate Gray
  var bottomRight = const Color(0xFF1C1C1C); // Light Rich Black
  var bottomLeft = const Color(0xFF404040); // Light Warm Dark Gray

  // "Love" Colors
  var loveTopLeft = const Color(0xFFDD7CA9); // Light Pink
  var loveTopRight = const Color(0xFFB33771); // Dark Pink
  var loveBottomRight = const Color(0xFFDD7CA9); // Light Pink
  var loveBottomLeft = const Color(0xFFB33771); // Dark Pink

  var transparent = const Color(0x00000000); // Transparent

  // Animation
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();

    // Initialize animation controller for like button
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Define the tween for animating the colors
    _likeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/music/song.mp3');
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position.inMilliseconds.toDouble();
        });
      });
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _totalDuration = duration?.inMilliseconds.toDouble() ?? 1;
        });
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _togglePlayPause() async {
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? await _audioPlayer.play() : await _audioPlayer.pause();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeAnimationController.forward();
      } else {
        _likeAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  // Helper method to blend colors based on the animation value
  Color _blendColor(Color color1, Color color2, double ratio) {
    final double inverseRatio = 1 - ratio;
    final int red = (color1.red * inverseRatio + color2.red * ratio).round();
    final int green =
        (color1.green * inverseRatio + color2.green * ratio).round();
    final int blue = (color1.blue * inverseRatio + color2.blue * ratio).round();
    return Color.fromRGBO(red, green, blue, 1);
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Animated Background Gradients in a Stack
          AnimatedBuilder(
            animation: _likeAnimation,
            builder: (context, child) {
              // Blend colors based on like animation
              final animatedTopLeftColor = _blendColor(
                topLeft,
                loveTopLeft,
                _likeAnimation.value,
              );
              final animatedTopRightColor = _blendColor(
                topRight,
                loveTopRight,
                _likeAnimation.value,
              );
              final animatedBottomRightColor = _blendColor(
                bottomRight,
                loveBottomRight,
                _likeAnimation.value,
              );
              final animatedBottomLeftColor = _blendColor(
                bottomLeft,
                loveBottomLeft,
                _likeAnimation.value,
              );

              return Stack(
                children: [
                  AnimatedContainer(
                    duration: _duration,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [animatedTopLeftColor, transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _duration,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [animatedTopRightColor, transparent],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _duration,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [animatedBottomRightColor, transparent],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _duration,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [animatedBottomLeftColor, transparent],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skeleton Loading Screen
          if (_loadingScreen)
            Container(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              child: Column(
                children: [
                  // Skeleton for the main container
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                      height: 400,
                      width: MediaQuery.of(context).size.width - 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Skeleton for the progress bar
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Container(
                          height: 3,
                          width: MediaQuery.of(context).size.width - 40,
                          color: const Color(0xFF2C2C2C),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 50,
                              height: 10,
                              color: const Color(0xFF2C2C2C),
                            ),
                            Container(
                              width: 50,
                              height: 10,
                              color: const Color(0xFF2C2C2C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Skeleton for the controls
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(45),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Main Content (Visible when loadingScreen is false)
          if (!_loadingScreen)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  // Keep the existing container
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
                              height: 404, // 150 + 4px border
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: _isLiked
                                      ? [
                                          const Color(0xFFDD7CA9)
                                              .withOpacity(0.5),
                                          const Color(0xFFDD7CA9)
                                              .withOpacity(0.8),
                                          const Color(0xFFDD7CA9)
                                              .withOpacity(0.5),
                                        ]
                                      : [
                                          const Color(0xFFDBD897)
                                              .withOpacity(0.5),
                                          const Color(0xFFDBD897)
                                              .withOpacity(0.8),
                                          const Color(0xFFDBD897)
                                              .withOpacity(0.5),
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 400,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLiked
                                  ? [
                                      const Color.fromARGB(255, 87, 55, 77)
                                          .withOpacity(0.8),
                                      const Color.fromARGB(255, 69, 46, 73)
                                          .withOpacity(0.8),
                                    ]
                                  : [
                                      const Color(0xFF2C2C2C).withOpacity(0.8),
                                      const Color(0xFF1A1A1A).withOpacity(0.8),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white,
                                  _isLiked
                                      ? Colors.pink
                                      : const Color(0xFFDBD897)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Generated music in your mood.",
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
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: const SliderThemeData(
                            trackHeight: 3,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8),
                            activeTrackColor: Color(0xFFDD7CA9),
                            inactiveTrackColor: Color(0xFFDBD897),
                          ),
                          child: Slider(
                            value: _currentPosition.clamp(0, _totalDuration),
                            min: 0,
                            max: _totalDuration,
                            onChanged: (value) async {
                              await _audioPlayer.seek(
                                  Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_currentPosition),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                _formatDuration(_totalDuration),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isLiked
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleLike,
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 90,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _audioPlayer.seek(Duration.zero);
                            if (!_isPlaying) _togglePlayPause();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.round());
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Alignment _getGradientAlignment(double value) {
    final angle = value * 4; // 0-4 for full rotation
    if (angle < 1) return Alignment(-1 + 2 * angle, -1); // Left to Top
    if (angle < 2) return Alignment(1, -1 + 2 * (angle - 1)); // Top to Right
    if (angle < 3) return Alignment(1 - 2 * (angle - 2), 1); // Right to Bottom
    return Alignment(-1, 1 - 2 * (angle - 3)); // Bottom to Left
  }
}