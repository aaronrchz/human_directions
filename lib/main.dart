import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/directions_screen.dart';
import 'package:human_directios/home_screen.dart';
import 'package:human_directios/human_directions.dart';

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
  void goToNearbyDirectionsScreen() async{
    HumanDirections testController = HumanDirections(openAiApiKey: widget.openAiApiKey, googleDirectionsApiKey: widget.googleDirectionsApiKey);
      await testController.getCurrentLocation(context);
      print(testController.currentPosition);
      await testController.gptPromptNearbyPlaces('Where can i get a drink', testController.currentPosition!); 
    setState(() {
      
      currentScreen = const 
      Scaffold(body: Text('Work in progress'),);
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