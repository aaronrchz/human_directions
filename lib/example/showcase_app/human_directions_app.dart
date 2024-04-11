import 'package:flutter/material.dart';
import 'screens/directions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/nearby_recommendations_screen.dart';
import 'screens/simplified_directions_screen.dart';

class HumanDirectionsApp extends StatefulWidget {
  const HumanDirectionsApp(
      {super.key,
      required this.googleDirectionsApiKey,
      required this.openAiApiKey});
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  @override
  State<HumanDirectionsApp> createState() => _HumanDirectionsAppState();
}

class _HumanDirectionsAppState extends State<HumanDirectionsApp> {
  late Widget currentScreen;
  late Widget previousScreen;
  late Widget auxScreen;
  void goToDirectionsScreen() {
    previousScreen = currentScreen;
    setState(() {
      currentScreen = DirectionsScreen(
        openAiApiKey: widget.openAiApiKey,
        googleDirectionsApiKey: widget.googleDirectionsApiKey,
        onBack: goToPrevious,
      );
    });
  }

  void goToNearbyDirectionsScreen() {
    previousScreen = currentScreen;
    setState(() {
      currentScreen = RequestDNearbyPlacesScreen(
        googleDirectionsApiKey: widget.googleDirectionsApiKey,
        openAiApiKey: widget.openAiApiKey,
        func: goToRecommendedPlaceScreen,
        onBack: goToPrevious,
      );
    });
  }

  void goToRecommendedPlaceScreen(String origin, String destination) {
    auxScreen = previousScreen;
    previousScreen = currentScreen;
    setState(() {
      currentScreen = SimplifiedDirectionsScreen(
        openAiApiKey: widget.openAiApiKey,
        googleDirectionsApiKey: widget.googleDirectionsApiKey,
        origin: origin,
        destination: destination,
        onBack: goToPrevious,
      );
    });
  }

  void goToPrevious() {
    setState(() {
      currentScreen = previousScreen;
      previousScreen = auxScreen;
    });
  }

  @override
  void initState() {
    super.initState();
    currentScreen = HomeScreen(
      onPressedHumanDirections: goToDirectionsScreen,
      onPressedDirectionsNearby: goToNearbyDirectionsScreen,
    );
    previousScreen = currentScreen;
    auxScreen = previousScreen;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human Directions v0',
      home: currentScreen,
    );
  }
}
