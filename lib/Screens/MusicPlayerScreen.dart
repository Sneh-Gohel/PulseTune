import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  bool _isPlaying = false;
  bool _isLoved = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );

    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/music/song.mp3'); // Load the music file
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _waveController.repeat(reverse: true);
      } else {
        _waveController.stop();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Audio Visualization Waves
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AudioWavePainter(
                      animationValue: _waveAnimation.value,
                      isPlaying: _isPlaying,
                    ),
                    size: Size(MediaQuery.of(context).size.width * 0.9, 200),
                  );
                },
              ),
            ),
          ),

          // Playback Controls
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Progress Bar
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _audioPlayer.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inMilliseconds.toDouble(),
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) async {
                            await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                          },
                          activeColor: const Color(0xFFDD7CA9),
                          inactiveColor: Colors.white24,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLoved ? Icons.favorite : Icons.favorite_border,
                        color: _isLoved ? Color(0xFFDD7CA9) : Colors.white70,
                        size: 30,
                      ),
                      onPressed: () => setState(() => _isLoved = !_isLoved),
                    ),

                    // Play/Pause Button
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDD7CA9), Color(0xFF2C2C2C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFDD7CA9).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isPlaying
                                ? const Icon(
                                    Icons.pause_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.autorenew_rounded,
                          color: Colors.white70, size: 30),
                      onPressed: () {
                        // Handle recompose
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class AudioWavePainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;

  AudioWavePainter({required this.animationValue, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFDD7CA9), Color(0xFF2C2C2C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final waveCount = 20;
    final waveWidth = size.width / waveCount;
    final random = Random();

    for (var i = 0; i < waveCount; i++) {
      final heightVariation = isPlaying
          ? (sin(animationValue * 2 * pi + i * 0.5) * 0.5 + 0.5
          ): 0.5;
      final waveHeight = size.height * 0.4 * heightVariation +
          random.nextDouble() * size.height * 0.1;

      final rect = Rect.fromLTRB(
        i * waveWidth + 4,
        (size.height - waveHeight) / 2,
        (i + 1) * waveWidth - 4,
        (size.height + waveHeight) / 2,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWavePainter oldDelegate) => true;
}