import 'package:flutter/material.dart' hide Step;
import 'package:google_directions_api/google_directions_api.dart';

class GoogleDirectionsSteps extends StatefulWidget {
  const GoogleDirectionsSteps({required this.steps, super.key});
  final List<Step>? steps;
  @override
  State<GoogleDirectionsSteps> createState() => _GoogleDirectiosStepsState();
}

class _GoogleDirectiosStepsState extends State<GoogleDirectionsSteps> {
  @override
  Widget build(BuildContext context) {
    int stepsCounter = 1;
    return SizedBox(
      height: 170,
      width: 390,
      child: Column(
        children: [
          const Text('Google Directions:'),
          SizedBox(
            height: 150,
            width: 390,
            child: SingleChildScrollView(
                child: Column(
              children: [
                ...?widget.steps?.map(
                  (e) {
                    /*if (kDebugMode) {
                                  print(
                                      '$stepsCounter - De: ${e.startLocation.toString()} Hacia: ${e.endLocation.toString()}, Instrucciones: ${e.instructions},Distancia:${e.distance?.text}  ,Duración Estimada:${e.duration?.text}  , Maniobra: ${e.maneuver} ');
                                }*/
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 15,
                            child: Container(
                                alignment: Alignment.topLeft,
                                child: Text((stepsCounter++).toString()))),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('De: ${e.startLocation.toString()}'),
                              Text('Hacia: ${e.endLocation.toString()}'),
                              Text('Distamcia: ${e.distance?.text}'),
                              Text('Duración Estimada: ${e.duration?.text} '),
                              Text('Instrucciones: ${e.instructions}'),
                              if (e.maneuver != null) Text('Maniobra: ${e.maneuver}'),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
