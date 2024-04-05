import 'package:flutter/material.dart';
import '../../../../components/llm/steps_parse.dart';

class HumanStepsWidget extends StatefulWidget {
  const HumanStepsWidget({required this.stringHumanDirections, super.key});
  final String stringHumanDirections;
  @override
  State<HumanStepsWidget> createState() => _HumanStepsWidgetState();
}

class _HumanStepsWidgetState extends State<HumanStepsWidget> {
  @override
  Widget build(BuildContext context) {
    try {
      HumanDirectionsOutput data =
          HumanDirectionsOutput.fromString(widget.stringHumanDirections);
      return SizedBox(
        height: 320,
        width: 390,
        child: Column(
          children: [
            const Text('Human Directions'),
            SizedBox(
              height: 300,
              width: 390,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      data.startMessage,
                    ),
                    ...data.steps.map(
                      (e) => Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.number.toString()),
                              const SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(e.instruction),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      data.endMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (exept) {
      return SizedBox(
        height: 320,
        width: 390,
        child: Column(
          children: [
            const Text('Human Directions'),
            SizedBox(
              height: 300,
              width: 390,
              child: SingleChildScrollView(
                child: Text(
                  widget.stringHumanDirections,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
