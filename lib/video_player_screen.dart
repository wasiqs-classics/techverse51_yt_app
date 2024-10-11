import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  VideoPlayerScreen({required this.videoId});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false; // Track full-screen state

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(() {
        if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
          setState(() {});
        }
      });
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
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Only show title bar when not in full-screen
            if (!_isFullScreen)
              Padding(
                padding: const EdgeInsets.only(
                    top: 40.0, left: 8.0, right: 8.0, bottom: 15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Playing lecture',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: YoutubePlayerBuilder(
                onExitFullScreen: () {
                  SystemChrome.setPreferredOrientations(
                      DeviceOrientation.values);
                  setState(() {
                    _isFullScreen = false;
                  });
                },
                onEnterFullScreen: () {
                  setState(() {
                    _isFullScreen = true;
                  });
                },
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  onReady: () {
                    _isPlayerReady = true;
                  },
                  onEnded: (data) {
                    _controller.seekTo(const Duration(seconds: 0));
                  },
                ),
                builder: (context, player) => Align(
                  alignment:
                      Alignment.topCenter, // Aligns the player at the top
                  child: player,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
