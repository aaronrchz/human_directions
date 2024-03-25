import 'package:flutter/material.dart' hide Step;
import 'package:google_directions_api/google_directions_api.dart';

class GoogleDirectionsSteps extends StatefulWidget {
  const GoogleDirectionsSteps({
    required this.steps,
    required this.nearbyPlacesFrom,
    required this.nearbyPlacesTo,
    super.key,
  });
  final List<Step>? steps;
  final List<String> nearbyPlacesFrom;
  final List<String> nearbyPlacesTo;
  @override
  State<GoogleDirectionsSteps> createState() => _GoogleDirectiosStepsState();
}

class _GoogleDirectiosStepsState extends State<GoogleDirectionsSteps> {
  @override
  Widget build(BuildContext context) {
    int stepsCounter = 1;
    int auxStepCounter = 0;
    int auxStepCounter1 = 0;
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
                              Text('From: ${e.startLocation.toString()}'),
                              Text(
                                  'Nearby places: ${widget.nearbyPlacesFrom[auxStepCounter++]}'),
                              Text('To: ${e.endLocation.toString()}'),
                              Text(
                                  'Nearby Places: ${widget.nearbyPlacesTo[auxStepCounter1++]}'),
                              Text('Distance: ${e.distance?.text}'),
                              Text('Estimated time: ${e.duration?.text} '),
                              Text('Instructions: ${e.instructions}'),
                              if (e.maneuver != null)
                                Text('Maneuver: ${e.maneuver}'),
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
