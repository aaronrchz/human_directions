import 'package:flutter/material.dart';
import 'package:human_directios/screens/widgets/custom_bg.dart';

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                onPressedDirectionsNearby();
              },
              child: const Text('Get directions to a nerby place'),
            ),
            ElevatedButton(
              onPressed: () {
                onPressedHumanDirections();
              },
              child: const Text('Get Custom directions'),
            )
          ],
        ),
      ),
    );
  }
}
