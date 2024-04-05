import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_directions/example/showcase_app/human_directions_app.dart';

void main() {
  test('Run showcase app', () {
    runApp(const HumanDirectionsApp(
      googleDirectionsApiKey: 'googleDirectionsApiKey',
      openAiApiKey: 'openAiApiKey',
    ));
  });
}
