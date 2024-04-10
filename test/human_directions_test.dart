//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_directions/components/distance_metrix.dart';
//import 'package:human_directions/example/showcase_app/human_directions_app.dart';

void main() async {
  test('test Distance Matrix', () async {
    final distanceMatrix = await getDistanceMatrix('YOUR_API_KEY', origins: [
      '35.088292431841694, -106.61910760086647',
    ], destinations: [
      '4200 Lomas Blvd NE, Albuquerque, NM 87110',
      '35.0831033940459, -106.61611343660347'
    ]);
    print(distanceMatrix);
    expect(distanceMatrix, isA<dynamic>());
  });
}
