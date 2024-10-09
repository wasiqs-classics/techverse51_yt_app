import 'package:flutter/material.dart';
import 'playlist.dart'; // Import the Playlist model
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Playlist>> playlists;

  @override
  void initState() {
    super.initState();
    playlists = loadPlaylists();
  }

  Future<List<Playlist>> loadPlaylists() async {
    final String apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    final String channelId = dotenv.env['YOUTUBE_CHANNEL_ID'] ?? '';
    const String baseUrl = 'https://www.googleapis.com/youtube/v3';

    final url =
        '$baseUrl/playlists?part=snippet&channelId=$channelId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawPlaylists = List<Map<String, dynamic>>.from(data['items']);
        return rawPlaylists.map((json) => Playlist.fromJson(json)).toList();
      } else {
        print('Failed to load playlists: ${response.statusCode}');
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
        title: Text('YouTube Playlists'),
      ),
      body: FutureBuilder<List<Playlist>>(
        future: playlists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading playlists'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No playlists available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final playlist = snapshot.data![index];
                return ListTile(
                  leading: Image.network(
                    playlist.thumbnailUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(playlist.title),
                );
              },
            );
          }
        },
      ),
    );
  }
}
