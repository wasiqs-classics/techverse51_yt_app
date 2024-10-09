import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'playlist.dart';
import 'home_screen.dart'; // Import HomeScreen here

Future<List<Map<String, dynamic>>> fetchPlaylists() async {
  final String apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  final String channelId = dotenv.env['YOUTUBE_CHANNEL_ID'] ?? '';
  const String baseUrl = 'https://www.googleapis.com/youtube/v3';

  final url =
      '$baseUrl/playlists?part=snippet&channelId=$channelId&key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['items']);
    } else {
      print('Failed to load playlists: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

Future<void> main() async {
  // Load the .env file from the assets folder
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Playlists App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
