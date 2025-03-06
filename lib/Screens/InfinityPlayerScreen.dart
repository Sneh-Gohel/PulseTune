// ignore_for_file: must_be_immutable, file_names, avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class InfinityPlayerScreen extends StatefulWidget {
  bool _isHeartbeatMusic = false;
  String url = "";
  String message = "";
  InfinityPlayerScreen(
      {required bool isHeartbeatMusic,
      required this.url,
      required this.message,
      super.key})
      : _isHeartbeatMusic = isHeartbeatMusic;

  @override
  State<InfinityPlayerScreen> createState() => _InfinityPlayerScreen();
}

class _InfinityPlayerScreen extends State<InfinityPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _totalDuration = 1;
  final Duration _duration = const Duration(milliseconds: 440);
  bool _loadingScreen = true; // Show loading screen initially
  bool _isGenerating = false; // Track if audio is being generated

  // Audio files
  File? _majorAudioFile;
  File? _secondaryAudioFile;

  double _majorVolume =
      1.0; // Volume for the major audio (starts at full volume)
  double _secondaryVolume =
      0.0; // Volume for the secondary audio (starts at zero volume)
  bool _isCrossfading = false; // Add this flag

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

    _initAudio();

    if (widget._isHeartbeatMusic) {
      _likeAnimationController.forward();
    } else {
      // Generate audio only if _isHeartbeatMusic is false
      _generateAndPlayAudio();
    }
  }

  Future<void> _initAudio() async {
    try {
      if (widget._isHeartbeatMusic) {
        // Load predefined audio for heartbeat music
        await _audioPlayer.setAsset('assets/music/song.mp3');
        setState(() {
          _loadingScreen = false;
          _isPlaying = true;
        });
      } else {
        // Load generated audio
        // await _generateAndPlayAudio();  // Moved this call to initState
      }

      // Listen to position updates
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position.inMilliseconds.toDouble();
          });

          // Check if 5 seconds are remaining in the major audio and crossfading is not in progress
          if (_totalDuration - _currentPosition <= 500 &&
              _secondaryAudioFile != null &&
              !_isCrossfading) {
            _startCrossfade();
          }
        }
      });

      // Listen to duration updates
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _totalDuration = duration?.inMilliseconds.toDouble() ?? 1;
          });
        }
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  Future<void> _playSecondaryAudio() async {
    if (_secondaryAudioFile != null) {
      try {
        // Load and play the secondary audio
        await _audioPlayer.setFilePath(_secondaryAudioFile!.path);
        await _audioPlayer.play();

        // Update state after successful play
        setState(() {
          _majorAudioFile = _secondaryAudioFile;
          _secondaryAudioFile = null;
          _majorVolume = 1.0;
          _secondaryVolume = 0.0;
          _isCrossfading = false; // Crossfading is complete
        });

        _audioPlayer.setVolume(_majorVolume);

        // Fetch the next secondary audio
        await _fetchSecondaryAudio();
      } catch (e) {
        print("Error playing secondary audio: $e");
      }
    }
  }

  void _startCrossfade() async {
    if (_isCrossfading) return; // Prevent multiple calls
    _isCrossfading = true; // Set the flag

    const int steps = 40;
    const Duration stepDuration = Duration(milliseconds: 50);

    // Start playing secondary audio with zero volume during crossfade
    if (_secondaryAudioFile != null) {
      await _audioPlayer.pause(); // Pause the current audio
      await _audioPlayer.setFilePath(_secondaryAudioFile!.path);
      await _audioPlayer.play();
      _audioPlayer.setVolume(0.0); // Initially, set the volume to 0
    }

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      if (mounted) {
        setState(() {
          _majorVolume = 1.0 - (i / steps);
          _secondaryVolume = i / steps;
        });
        _audioPlayer.setVolume(
            _secondaryVolume); // Gradually increase the volume of the secondary audio
      }
    }

    // After crossfade, switch to the secondary audio
    await _playSecondaryAudio();
  }

  String generate6CharCode() {
    const String lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';

    // Combine all possible characters for the first 5 characters
    const String allChars = lowercaseLetters + uppercaseLetters + numbers;

    // Combine only alphabets for the last character
    const String alphabets = lowercaseLetters + uppercaseLetters;

    // Create a Random object
    final Random random = Random();

    // Generate the first 5 characters
    String code = '';
    for (int i = 0; i < 5; i++) {
      // Pick a random index from the combined characters
      int randomIndex = random.nextInt(allChars.length);
      // Append the character at the random index to the code
      code += allChars[randomIndex];
    }

    // Generate the last character (must be an alphabet)
    int randomIndex = random.nextInt(alphabets.length);
    code += alphabets[randomIndex];
    print(code);

    return code;
  }

  Future<void> _switchToSecondaryAudio() async {
    if (_secondaryAudioFile != null) {
      await _audioPlayer.setFilePath(_secondaryAudioFile!.path);
      _audioPlayer.play();

      // Set the secondary audio as the major audio
      _majorAudioFile = _secondaryAudioFile;
      _secondaryAudioFile = null;

      // Fetch the next secondary audio
      await _fetchSecondaryAudio();
    }
  }

  Future<void> _fetchSecondaryAudio() async {
    final file = await _generateAudioFile();
    if (file != null) {
      setState(() {
        _secondaryAudioFile = file;
      });
    }
  }

  Future<File?> _generateAudioFile() async {
    String serverIP = "";

    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch the document from the "Server" collection with ID "Current_ip"
      final docSnapshot =
          await firestore.collection('Server').doc('Current_ip').get();

      if (docSnapshot.exists) {
        // Extract the IP address from the document
        final ipAddress = docSnapshot.data()?['ip'] ?? "No IP found";
        setState(() {
          serverIP = ipAddress;
        });
        print('Fetched server IP: $serverIP');
      } else {
        print('Error: Firestore document "Current_ip" does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching server IP from Firestore: $e');
      return null;
    }

    final Uri url = Uri.parse('http://$serverIP:5000/run-script');
    print('Sending request to: $url');

    final Map<String, dynamic> requestData = {
      "api": "prompt_gen", // Replace with your API key
      "prompt": widget.message, // Use the message as the prompt
      "duration": 60, // Set the duration (in seconds)
      "name": generate6CharCode(), // Set the name of the file
    };

    try {
      final http.Response response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 120));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Save the audio file locally
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${requestData["name"]}.mp3');
        await file.writeAsBytes(bytes);

        print('Audio saved to: ${file.path}');
        return file;
      } else {
        print('Failed to generate audio. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<void> _generateAndPlayAudio() async {
    if (widget._isHeartbeatMusic) {
      print("Hello"); // Print "Hello" if _isHeartbeatMusic is true
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Fetch the major audio
    _majorAudioFile = await _generateAudioFile();
    if (_majorAudioFile != null) {
      print("Got the first audio: ${_majorAudioFile!.path}");
      await _audioPlayer.setFilePath(_majorAudioFile!.path);
      _audioPlayer.play();

      // Update state to indicate that the audio is playing
      setState(() {
        _isPlaying = true;
        _loadingScreen = false;
        _isGenerating = false;
        print("screens are sets to off");
      });

      // Fetch the secondary audio
      await _fetchSecondaryAudio();
    }

    setState(() {
      _isGenerating = false;
    });
  }

  void _togglePlayPause() async {
    if (mounted) {
      setState(() => _isPlaying = !_isPlaying);
      if (_isPlaying) {
        _audioPlayer.play();
      } else {
        await _audioPlayer.pause();
      }
    }
  }

  void _regenerateMusic() async {
    setState(() {
      _isGenerating = true;
    });

    // Regenerate the major audio
    _majorAudioFile = await _generateAudioFile();
    if (_majorAudioFile != null) {
      print("Regenerated the major audio: ${_majorAudioFile!.path}");
      await _audioPlayer.setFilePath(_majorAudioFile!.path);
      _audioPlayer.play();

      // Update state to indicate that the audio is playing
      setState(() {
        _isPlaying = true;
        _loadingScreen = false;
      });

      // Fetch the secondary audio
      await _fetchSecondaryAudio();
    }

    setState(() {
      _isGenerating = false;
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
        title: Text(
          widget._isHeartbeatMusic ? 'Sync Your Music with 💗' : widget.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          if (_loadingScreen || _isGenerating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          widget._isHeartbeatMusic
                              ? const Color(0xFFDD7CA9)
                              : const Color(0xFFDBD897)),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 30),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          widget._isHeartbeatMusic
                              ? const Color(0xFFDD7CA9)
                              : const Color(0xFFDBD897)
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Generating and playing tracks you want...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Analyzing text patterns\nGenerating musical elements\nFinalizing composition',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Main Content (Visible when loadingScreen is false)
          if (!_loadingScreen && !_isGenerating)
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
                                  colors: widget._isHeartbeatMusic
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
                              colors: widget._isHeartbeatMusic
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
                                  widget._isHeartbeatMusic
                                      ? Colors.pink
                                      : const Color(0xFFDBD897)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: widget._isHeartbeatMusic
                                    ? Column(
                                        children: [
                                          Lottie.asset(
                                            'assets/lotties/heart.json',
                                            fit: BoxFit.cover,
                                            repeat: true,
                                            height: 250,
                                          ),
                                          const Text(
                                            "100",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 50,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Hero(
                                        tag: widget.message,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.asset(
                                            widget.url,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
                            value: _currentPosition.clamp(100, 100),
                            min: 0,
                            max: 100,
                            onChanged: (value) async {
                              await _audioPlayer
                                  .seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Live",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Live",
                                style: TextStyle(color: Colors.white70),
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
                        const IconButton(
                          icon: Icon(
                            Icons.favorite, // Add the missing icon data
                            color: Colors.transparent,
                            size: 30,
                          ),
                          onPressed: null,
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
                          onPressed: _regenerateMusic,
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

  Alignment _getGradientAlignment(double value) {
    final angle = value * 4; // 0-4 for full rotation
    if (angle < 1) return Alignment(-1 + 2 * angle, -1); // Left to Top
    if (angle < 2) return Alignment(1, -1 + 2 * (angle - 1)); // Top to Right
    if (angle < 3) return Alignment(1 - 2 * (angle - 2), 1); // Right to Bottom
    return Alignment(-1, 1 - 2 * (angle - 3)); // Bottom to Left
  }
}
