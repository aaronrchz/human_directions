import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/screens/directions_screen.dart';
import 'package:human_directios/screens/home_screen.dart';
import 'package:human_directios/screens/nearby_directions_screen.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  runApp(HumanDirectionsApp());
}

class HumanDirectionsApp extends StatefulWidget {
  HumanDirectionsApp({super.key});
  final String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? 'NO SUCH KEY';
  final String googleDirectionsApiKey =
      dotenv.env['GOOGLE_DIRECTIOS_API_KEY'] ?? 'NO SUCH KEY';
  @override
  State<HumanDirectionsApp> createState() => _HumanDirectionsAppState();
}

class _HumanDirectionsAppState extends State<HumanDirectionsApp>{
  late Widget currentScreen;
  void goToDirectionsScreen(){
    setState(() {
      currentScreen = DirectionsScreen(openAiApiKey: widget.openAiApiKey, googleDirectionsApiKey: widget.googleDirectionsApiKey);
    });
  }
  void goToNearbyDirectionsScreen() {
    setState(() {
      currentScreen = RequestDNearbyPlacesScreen(googleDirectionsApiKey: widget.googleDirectionsApiKey, openAiApiKey: widget.openAiApiKey);
    });
  }
  void goToRecommendedPlaceScreen(){
    setState(() {
      
    });
  }
  @override
  void initState(){
    super.initState();
    currentScreen =  HomeScreen( onPressedHumanDirections:goToDirectionsScreen,onPressedDirectionsNearby: goToNearbyDirectionsScreen,);
  }
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Human Directions v0',
      home:currentScreen,
    );
  }
}