import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/example/showcase_app/human_directions_app.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  final String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? 'NO SUCH KEY';
  final String googleDirectionsApiKey =
      dotenv.env['GOOGLE_DIRECTIOS_API_KEY'] ?? 'NO SUCH KEY';

  runApp(HumanDirectionsApp(
    googleDirectionsApiKey: googleDirectionsApiKey,
    openAiApiKey: openAiApiKey,
  ));
}
