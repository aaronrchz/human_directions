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
                  'Human directions, es un paquete que intenta mejorar las indicaciones de navegación GPS, usando inteligencia artificial para reorganizar dichas indicaciones a un vocabulario más familiar y entendible para cualquier persona.',
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
                child: const Text('Recomendaciónes de lugares cercanos'),
              ),
              ElevatedButton(
                onPressed: () {
                  onPressedHumanDirections();
                },
                child: const Text('Direcciones basadas en origen y destino'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
