import 'dart:convert';

/// The class that represents one single step from the human directions.
/// it parses and holds the data from the LLM.
class HumanDirectionsStep {
  final int number;
  final String instruction;

  HumanDirectionsStep({required this.number, required this.instruction});

  factory HumanDirectionsStep.fromJson(Map<String, dynamic> json) {
    return HumanDirectionsStep(
        number: json['number'], instruction: json['instruction']);
  }
}

class HumanDirectionsOutput {
  final String startMessage;
  final List<HumanDirectionsStep> steps;
  final String endMessage;

  HumanDirectionsOutput({
    required this.startMessage,
    required this.steps,
    required this.endMessage,
  });

  factory HumanDirectionsOutput.fromString(String rawData) {
    Map<String, dynamic> data = jsonDecode(rawData);
    return HumanDirectionsOutput(
        startMessage: data['start_message'],
        steps: (data['steps'] as List)
            .map((item) => HumanDirectionsStep.fromJson(item))
            .toList(),
        endMessage: data['end_message']);
  }
}
