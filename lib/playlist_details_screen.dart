import 'package:flutter/material.dart';
import 'package:techverse51_yt_app/video_player_screen.dart';
import 'video.dart'; // Import the Video model
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistId;
  final String playlistTitle;

  PlaylistDetailsScreen(
      {required this.playlistId, required this.playlistTitle});

  @override
  _PlaylistDetailsScreenState createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  late Future<List<Video>> videos;

  @override
  void initState() {
    super.initState();
    videos = fetchVideos(widget.playlistId);
  }

  Future<List<Video>> fetchVideos(String playlistId) async {
    final String apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    const String baseUrl = 'https://www.googleapis.com/youtube/v3';
    final url =
        '$baseUrl/playlistItems?part=snippet&maxResults=10&playlistId=$playlistId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawVideos = List<Map<String, dynamic>>.from(data['items']);
        return rawVideos.map((json) => Video.fromJson(json)).toList();
      } else {
        print('Failed to load videos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistTitle),
      ),
      body: FutureBuilder<List<Video>>(
        future: videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading videos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No videos available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final video = snapshot.data![index];
                return ListTile(
                  leading: Image.network(
                    video.thumbnailUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(video.title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoId: video.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
