import 'package:flutter/material.dart';
import '../../../components/llm/supported_languages.dart';
import '../../../components/metrics.dart';
import '../../../human_directions.dart';
import 'dart:async';

import '../screens/widgets/google_directios_steps_widget.dart';
import '../screens/widgets/human_directios_widget.dart';
import '../screens/widgets/request_status_widgets.dart';

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen(
      {required this.openAiApiKey,
      required this.googleDirectionsApiKey,
      required this.onBack,
      super.key});
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  final Function() onBack;
  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  String origin = '';
  String destination = '';
  String requestResult = '';
  Distance resolvedDistance = Distance(text: 'unknown', value: 0);
  Time resolvedTime = Time(text: 'unknown', value: 0);
  bool useGeoLocation = false;
  bool enableDirectionsButton = true;

  late HumanDirections directions;

  Widget googleDirectionsStepsWidget = const WaitingForUserInput();
  Widget humanDirectionsWidget = const WaitingForUserInput();
  final TextEditingController _originFieldController = TextEditingController();
  final TextEditingController _destinationFieldController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    directions = HumanDirections(
      openAiApiKey: widget.openAiApiKey,
      googleDirectionsApiKey: widget.googleDirectionsApiKey,
      openAIlanguage: OpenAILanguage.en,
      googlelanguage: 'en',
      placesRadius: 50,
    );
    _originFieldController.text = '34 Bd Garibaldi, 75015 Paris, Francia';
    _destinationFieldController.text =
        'Champ de Mars, 5 Av. Anatole France, 75007 Paris, Francia';
  }

  void _fetchDirections() async {
    if (useGeoLocation) {
      directions.fetchHumanDirectionsFromLocation(destination, context);
    } else {
      directions.fetchHumanDirections(origin, destination);
    }
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
          requestResult = directions.directionsAPIRequestResultStatus;
          resolvedDistance = directions.resolvedDistance;
          resolvedTime = directions.resolvedTime;
          googleDirectionsStepsWidget = GoogleDirectionsSteps(
            steps: directions.steps,
            nearbyPlacesFrom: directions.nearbyPlacesFrom,
            nearbyPlacesTo: directions.nearbyPlacesTo,
          );
        }
        if (directions.fetchResultFlag > 1) {
          googleDirectionsStepsWidget =
              ErrorOnRequestWidget(directions.directionsRequestResult);
          humanDirectionsWidget = ErrorOnRequestWidget(
              'Error on directions_api ${directions.directionsRequestResult}');
          timer.cancel();
        }
        if (directions.fetchHumanDirectionsFlag > 1) {
          humanDirectionsWidget = ErrorOnRequestWidget(
              directions.updateFetchHumanDirections ?? 'Unknown error');
          timer.cancel();
        }
        if (directions.fetchHumanDirectionsFlag == 0) {
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

  void _getUserFieldsAndFetchHumanDirections() {
    String tempOrigin = _originFieldController.text;
    String tempDestination = _destinationFieldController.text;
    if (tempOrigin.isNotEmpty && tempDestination.isNotEmpty) {
      origin = tempOrigin;
      destination = tempDestination;
      _fetchDirections();
    } else {
      setState(() {
        googleDirectionsStepsWidget =
            const ErrorOnRequestWidget('invalid input');
        humanDirectionsWidget = const ErrorOnRequestWidget('invalid input');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Human Direction v0'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: useGeoLocation,
                      onChanged: (bool? value) async {
                        enableDirectionsButton = false;
                        setState(() {
                          useGeoLocation = value!;
                        });
                        if (useGeoLocation) {
                          await directions.getCurrentLocation(context);
                          if (directions.currentPosition != null) {
                            _originFieldController.text =
                                'Latitude: ${directions.currentPosition!.latitude}, Longitude: ${directions.currentPosition!.longitude}';
                          }
                        } else {
                          _originFieldController.clear();
                        }
                        enableDirectionsButton = true;
                        setState(() {});
                      },
                    ),
                    const Text(
                      'Use Location',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                TextField(
                  controller: _originFieldController,
                  enabled: !useGeoLocation,
                  decoration: const InputDecoration(
                    labelText: 'Origin',
                  ),
                ),
                TextField(
                  controller: _destinationFieldController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: enableDirectionsButton
                          ? _getUserFieldsAndFetchHumanDirections
                          : null,
                      child: const Text('Get Directions'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text('Request Status: $requestResult'),
                        Text(('Total Distance: ${resolvedDistance.text}')),
                        Text('Total Time: ${resolvedTime.text}'),
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
