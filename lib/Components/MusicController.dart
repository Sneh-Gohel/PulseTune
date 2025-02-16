import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MusicController extends StatefulWidget {
  const MusicController({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MusicControllerState createState() => _MusicControllerState();
}

class _MusicControllerState extends State<MusicController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.heart,
              color: Colors.white,
              size: 45,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 45,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 45,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
