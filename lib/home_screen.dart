import 'package:flutter/material.dart';
import 'playlist.dart';
import 'playlist_details_screen.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Playlist>>(
          future: playlists,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading playlists'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No playlists available'));
            } else {
              return ListView.builder(
                itemCount:
                    snapshot.data!.length + 1, // Additional item for the title
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Display the title at the top of the list
                    return const Padding(
                      padding: EdgeInsets.only(top: 28.0, bottom: 10.0),
                      child: Text(
                        'Techverse51 Courses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    final playlist = snapshot.data![index - 1];
                    return PlaylistCard(
                      playlist: playlist,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistDetailsScreen(
                              playlistId: playlist.id,
                              playlistTitle: playlist.title,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class PlaylistCard extends StatefulWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistCard({required this.playlist, required this.onTap, Key? key})
      : super(key: key);

  @override
  _PlaylistCardState createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: _isHovering ? 4 : 2,
              blurRadius: _isHovering ? 8 : 4,
              offset: _isHovering ? Offset(0, 4) : Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  widget.playlist.thumbnailUrl,
                  width: 160,
                  height: 160 * 9 / 16, // maintaining 16:9 aspect ratio
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.playlist.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
