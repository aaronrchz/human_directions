import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/componets/location.dart';
import 'package:human_directios/directions_screen.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  runApp( const GeolocatorAppExample());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? 'NO SUCH KEY';
  final String googleDirectionsApiKey =
      dotenv.env['GOOGLE_DIRECTIOS_API_KEY'] ?? 'NO SUCH KEY';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human Directions v0',
      home: DirectionsScreen(
        openAiApiKey: openAiApiKey,
        googleDirectionsApiKey: googleDirectionsApiKey,
      ),
    );
  }
}
