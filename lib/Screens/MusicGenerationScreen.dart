import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'package:plusetune/Screens/MusicPlayerScreen.dart';

class MusicGenerationScreen extends StatefulWidget {
  const MusicGenerationScreen({super.key});

  @override
  State<MusicGenerationScreen> createState() => _MusicGenerationScreenState();
}

class _MusicGenerationScreenState extends State<MusicGenerationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  int _selectedDuration = 30;
  bool _isGenerating = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<int> _durations = [30, 45, 60, 120];
  int _remainingWords = 150;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _generateMusic() {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    // Simulate generation process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        Navigator.of(context).push(
          ScreenChanger.slideUpTransition(const MusicPlayerScreen()),
        );
      }
    });
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${(seconds / 60).floor()}min';
  }

  void _updateWordCount(String text) {
    final words = text.split(RegExp(r'\s+'));
    setState(() {
      _remainingWords = 150 - words.length;
      if (_remainingWords < 0) _remainingWords = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Compose Your Music',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Section
                GradientBorderContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Describe your music',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        maxLines: 5,
                        maxLength: 150,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: _updateWordCount,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                              'e.g., "A joyful piano melody with birds singing in the background"',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2C).withOpacity(0.8),
                          counterText: '$_remainingWords words remaining',
                          counterStyle: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Duration Selection
                const Text(
                  'Select Duration',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _durations.map((duration) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDuration = duration),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedDuration == duration
                              ? const Color(0xFFDD7CA9).withOpacity(0.2)
                              : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedDuration == duration
                              ? Border.all(
                                  color: const Color(0xFFDD7CA9), width: 1.5)
                              : null,
                        ),
                        child: Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: _selectedDuration == duration
                                ? const Color(0xFFDD7CA9)
                                : Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // Generate Button
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    onPressed: _generateMusic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD7CA9),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Generate Music',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isGenerating)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFDD7CA9)),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 30),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFDD7CA9)],
                      ).createShader(bounds),
                      child: const Text(
                        'Composing your masterpiece...',
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
        ],
      ),
    );
  }
}

class GradientBorderContainer extends StatelessWidget {
  final Widget child;

  const GradientBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFDD7CA9), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}
