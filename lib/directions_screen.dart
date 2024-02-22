import 'package:flutter/material.dart';
import 'package:human_directios/human_directions.dart';
import 'dart:async';

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen(
      {required this.openAiApiKey,
      required this.googleDirectionsApiKey,
      super.key});
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  late HumanDirections directions;

  String origin =
      "Porte d'Aix, 19 Pl. Jules Guesde, 13003 Marseille, Francia";
  String destination =
      'Aix-Marseille University, 3 Pl. Victor Hugo, 13331 Marseille, Francia';
  @override
  void initState() {
    super.initState();
    _fetchDirections();
  }

  void _fetchDirections() async {
    directions = HumanDirections( 
        openAiApiKey: widget.openAiApiKey,
        googleDirectionsApiKey: widget.googleDirectionsApiKey);
    directions.fetchHumanDirections(origin, destination);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (directions.fetchResultFlag == 0 &&
            directions.fetchHumanDirectionsFlag == 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int stepsCounter = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Human Direction v0'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
          child: Column(
            children: [
              Text('Origen: $origin'),
              Text('Destino: $destination'),
              Text(directions.requestResult),
              Text((directions.resolvedDistance.text ?? '0')),
              Text(directions.resolvedTime.text ?? '0'),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 300,
                width: 390,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...?directions.steps?.map(
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
                                      child:
                                          Text((stepsCounter++).toString()))),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text('De: ${e.startLocation.toString()}'),
                                    Text('Hacia: ${e.endLocation.toString()}'),
                                    Text('Distamcia: ${e.distance?.text}'),
                                    Text(
                                        'Duración Estimada: ${e.duration?.text} '),
                                    Text('Instrucciones: ${e.instructions}'),
                                    if (e.maneuver != null)
                                      Text('Maniobra: ${e.maneuver}'),
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
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Human Directions:'),
              SizedBox(
                height: 200,
                width: 390,
                child: SingleChildScrollView(
                  child: Text(
                    (directions.updateFetchHumanDirections ??
                        'Error on gpt prompt'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
