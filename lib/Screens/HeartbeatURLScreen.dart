// ignore_for_file: file_names, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plusetune/Components/ScreenChanger.dart';
import 'package:plusetune/Screens/InfinityPlayerScreen.dart';

class HeartbeatURLScreen extends StatefulWidget {
  const HeartbeatURLScreen({super.key});

  @override
  State<HeartbeatURLScreen> createState() => _HeartbeatURLScreenState();
}

class _HeartbeatURLScreenState extends State<HeartbeatURLScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isButtonActive = false;
  bool loadingScreen = false;

  @override
  void initState() {
    super.initState();
    get_auto_login_file();
    _urlController.addListener(() {
      setState(() {
        _isButtonActive = _urlController.text.isNotEmpty;
      });
    });
  }

  Future<void> get_auto_login_file() async {
    setState(() {
      loadingScreen = true;
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/heartbeat.txt');
      bool fileExists = file.existsSync();
      if (fileExists) {
        String fileContent = await file.readAsString();
        setState(() {
          _urlController.text = fileContent;
        });
      }
    } catch (e) {
      SnackBar(
        content: Text("Error reading login file. Exception: $e"),
      );
    } finally {
      setState(() {
        loadingScreen = false;
      });
    }
  }

  Future<void> generate_auto_login_file() async {
    setState(() {
      loadingScreen = true;
    });
    try {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      final storageStatus = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
      if (storageStatus == PermissionStatus.granted) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/heartbeat.txt');
        await file.writeAsString(
            _urlController.text.trim()); // Write the URL to the file
        print("File is generated");
      } else {
        const SnackBar(
          content: Text("Error generating login file."),
        );
      }
    } catch (e) {
      SnackBar(
        content: Text("Error generating login file. Exception: $e"),
      );
    } finally {
      setState(() {
        loadingScreen = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // Helper method to build gradient border container
  Widget _buildGradientBorderContainer({required Widget child}) {
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
          'Enter Hyperate URL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGradientBorderContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hyperate URL',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _urlController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Paste your Hyperate URL here',
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2C).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 200, // Adjust width as desired
                    child: ElevatedButton(
                      onPressed: _isButtonActive
                          ? () async {
                              await generate_auto_login_file();
                              Navigator.of(context).pushAndRemoveUntil(
                                ScreenChanger.slideUpTransition(
                                    InfinityPlayerScreen(
                                  isHeartbeatMusic: true,
                                  heartbeatURL: _urlController.text.trim(),
                                  url: "",
                                  message: "",
                                )),
                                (route) => false,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonActive
                            ? const Color(0xFFDD7CA9)
                            : const Color(0xFFDD7CA9).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: _isButtonActive ? 4 : 0,
                      ),
                      child: const Text(
                        'Sync Now! 💕',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Steps to get Hyperate URL:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '1. Download and open the Hyperate app on your phone and smartwatch.\n'
                  '2. Connect your smartwatch from the mobile application.\n'
                  '3. Start a recording session.\n'
                  '4. Once your session is start, Copy the URL shown below you current heartrate.\n'
                  '5. Paste the copied URL into the text field above.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (loadingScreen)
            Container(
              color: const Color(0xFF1A1A1A).withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFDD7CA9)),
              ),
            ),
        ],
      ),
    );
  }
}
