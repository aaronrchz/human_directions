import 'package:flutter/material.dart';
import 'package:human_directios/componets/supported_lenguages.dart';
import 'package:human_directios/human_directions.dart';
import 'dart:async';

import 'package:human_directios/widgets/google_directios_steps_widget.dart';
import 'package:human_directios/widgets/human_directios_widget.dart';
import 'package:human_directios/widgets/request_status_widgets.dart';

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
  String origin = '';
  String destination = '';
  String requestResult = '';
  Distance resolvedDistance = Distance();
  Time resolvedTime = Time();

  Widget googleDirectionsStepsWidget = const WaitingForUserInput();
  Widget humanDirectionsWidget = const WaitingForUserInput();
  final TextEditingController _originFieldController = TextEditingController();
  final TextEditingController _destinationFieldController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _originFieldController.text = '34 Bd Garibaldi, 75015 Paris, Francia';
    _destinationFieldController.text = 'Champ de Mars, 5 Av. Anatole France, 75007 Paris, Francia';
  }

  void _fetchDirections() async {
    HumanDirections directions = HumanDirections(
        openAiApiKey: widget.openAiApiKey,
        googleDirectionsApiKey: widget.googleDirectionsApiKey,
        openAIlenguage: OpenAILenguage.es,
        googlelenguage: 'es-419',
        );
    directions.fetchHumanDirections(origin, destination);
    setState(() {
      googleDirectionsStepsWidget = const WaitingRequestResult(
          statusMessage:
              'Awaiting google directions Results\nPlease Hold on...');
      humanDirectionsWidget = const WaitingRequestResult(
          statusMessage:
              'Awaiting openAI directions Results\nPlease Hold on...');
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (directions.fetchResultFlag == 0) {
          requestResult = directions.requestResult;
          resolvedDistance = directions.resolvedDistance;
          resolvedTime = directions.resolvedTime;
          print(directions.nearbyPlacesFrom.length);
          googleDirectionsStepsWidget = GoogleDirectionsSteps(
            steps: directions.steps,
            nearbyPlacesFrom: directions.nearbyPlacesFrom,
            nearbyPlacesTo: directions.nearbyPlacesTo,
          );
        }
        if (directions.humanDirectionsFlag == 0) {
          humanDirectionsWidget = HumanStepsWidget(
              stringHumanDirections:
                  directions.updateFetchHumanDirections ?? 'ERROR');
        }
        if (directions.fetchResultFlag == 0 &&
            directions.fetchHumanDirectionsFlag == 0) {
          timer.cancel();
        }
      });
    });
  }

  void _getUserFields() {
    String tempOrigin = _originFieldController.text;
    String tempDestination = _destinationFieldController.text;
    if (tempOrigin.isNotEmpty && tempDestination.isNotEmpty) {
      origin = tempOrigin;
      destination = tempDestination;
      _fetchDirections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Human Direction v0'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
            child: Column(
              children: [
                TextField(
                  controller: _originFieldController,
                  
                  decoration: const InputDecoration(
                    labelText: 'Origen',
                  ),
                ),
                TextField(
                  controller: _destinationFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _getUserFields,
                      child: const Text('Get Directions'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text('Request Status: $requestResult'),
                        Text(
                            ('Total Distance: ${resolvedDistance.text ?? '0'}')),
                        Text('Total Time: ${resolvedTime.text ?? '0'}'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                googleDirectionsStepsWidget,
                const SizedBox(
                  height: 10,
                ),
                humanDirectionsWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
