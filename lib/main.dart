import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/screens/directions_screen.dart';
import 'package:human_directios/screens/home_screen.dart';
import 'package:human_directios/screens/nearby_directions_screen.dart';
import 'package:human_directios/screens/simplified_directions_screen.dart';

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
  late Widget previousScreen;
  late Widget auxScreen;
  void goToDirectionsScreen(){
    previousScreen = currentScreen;
    setState(() {
      currentScreen = DirectionsScreen(openAiApiKey: widget.openAiApiKey, googleDirectionsApiKey: widget.googleDirectionsApiKey, onBack: goToPrevious,);
    });
  }
  void goToNearbyDirectionsScreen() {
    previousScreen = currentScreen;
    setState(() {
      currentScreen = RequestDNearbyPlacesScreen(googleDirectionsApiKey: widget.googleDirectionsApiKey, openAiApiKey: widget.openAiApiKey, func: goToRecommendedPlaceScreen ,onBack: goToPrevious,);
    });
  }
  void goToRecommendedPlaceScreen(String origin, String destination){
    auxScreen =previousScreen;
    previousScreen = currentScreen;
    setState(() {
      currentScreen = SimplifiedDirectionsScreen(openAiApiKey: widget.openAiApiKey, googleDirectionsApiKey: widget.googleDirectionsApiKey, origin: origin, destination: destination,onBack: goToPrevious,);
    });
  }
  void goToPrevious(){
    setState(() {
      currentScreen = previousScreen;
      previousScreen = auxScreen;
    });
  }
  @override
  void initState(){
    super.initState();
    currentScreen =  HomeScreen( onPressedHumanDirections:goToDirectionsScreen,onPressedDirectionsNearby: goToNearbyDirectionsScreen,);
    previousScreen = currentScreen;
    auxScreen = previousScreen;
  }
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Human Directions v0',
      home:currentScreen,
    );
  }
}