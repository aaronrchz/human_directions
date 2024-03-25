import 'package:flutter/material.dart';
import 'package:human_directios/example/showcase_app/screens/widgets/custom_bg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {required this.onPressedDirectionsNearby,
      required this.onPressedHumanDirections,
      super.key});
  final Function() onPressedHumanDirections;
  final Function() onPressedDirectionsNearby;
  @override
  Widget build(BuildContext context) {
    return CustomBackgraoud(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Human Directions v0 Showcase',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                  'Human directions is a package that tries to improve the instructions given by a GPS navigation system, using AI to re-organize said instructions to a more familiar vocabulary, understandable to almost anyone',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  )),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  onPressedDirectionsNearby();
                },
                child: const Text('Nearby places recommendations search'),
              ),
              ElevatedButton(
                onPressed: () {
                  onPressedHumanDirections();
                },
                child: const Text('Origin - destination based directions'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
