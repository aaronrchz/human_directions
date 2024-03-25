import 'package:flutter/material.dart';
import '../../../components/llm/supported_languages.dart';
import '../../../human_directions.dart';
import 'dart:async';

import '../screens/widgets/google_directios_steps_widget.dart';
import '../screens/widgets/human_directios_widget.dart';
import '../screens/widgets/request_status_widgets.dart';

class SimplifiedDirectionsScreen extends StatefulWidget {
  const SimplifiedDirectionsScreen(
      {required this.openAiApiKey,
      required this.googleDirectionsApiKey,
      required this.origin,
      required this.destination,
      required this.onBack,
      super.key});
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  final String origin;
  final String destination;
  final Function() onBack;
  @override
  State<SimplifiedDirectionsScreen> createState() =>
      _SimplifiedDirectionsScreenState();
}

class _SimplifiedDirectionsScreenState
    extends State<SimplifiedDirectionsScreen> {
  String origin = '';
  String destination = '';
  String requestResult = '';
  Distance resolvedDistance = Distance();
  Time resolvedTime = Time();
  bool useGeoLocation = false;
  bool enableDirectionsButton = true;
  late Timer _timer;

  late HumanDirections directions;

  Widget googleDirectionsStepsWidget = const WaitingForUserInput();
  Widget humanDirectionsWidget = const WaitingForUserInput();
  @override
  void initState() {
    super.initState();
    directions = HumanDirections(
      openAiApiKey: widget.openAiApiKey,
      googleDirectionsApiKey: widget.googleDirectionsApiKey,
      openAIlanguage: OpenAILanguage.en,
      googlelanguage: 'en',
      placesRadious: 50,
    );
    _getUserFieldsAndFetchHumanDirections();
  }

  @override
  void dispose() {
    _timer.cancel(); // Detiene el temporizador cuando la pantalla se destruye
    super.dispose();
  }

  void _fetchDirections() async {
    if (useGeoLocation) {
      directions.fetchHumanDirectionsFromLocation(destination);
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (directions.fetchResultFlag == 0) {
          requestResult = directions.requestResult;
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
        if (directions.humanDirectionsFlag > 1) {
          humanDirectionsWidget = ErrorOnRequestWidget(
              directions.updateFetchHumanDirections ?? 'Unknown error');
          timer.cancel();
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

  void _getUserFieldsAndFetchHumanDirections() {
    String tempOrigin = widget.origin;
    String tempDestination = widget.destination;
    if (tempOrigin.isNotEmpty && tempDestination.isNotEmpty) {
      origin = tempOrigin;
      destination = tempDestination;
      _fetchDirections();
    } else {
      setState(() {
        googleDirectionsStepsWidget =
            const ErrorOnRequestWidget('Invalid input');
        humanDirectionsWidget = const ErrorOnRequestWidget('Invalid input');
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
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
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
