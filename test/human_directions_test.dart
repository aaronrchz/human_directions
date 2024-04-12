//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:human_directions/components/distance_matrix.dart';
//import 'package:human_directions/example/showcase_app/human_directions_app.dart';

void main() async {
  test('test Distance Matrix', () async {
    final distanceMatrix =
        await getDistanceMatrix('AIzaSyAiCuvv9hmJM1EmMOKPDWiHKwaEmSldAms',
            origins: [
              '35.088292431841694, -106.61910760086647',
              '35.12869686156047, -106.61634682382963',
            ],
            destinations: [
              '4200 Lomas Blvd NE, Albuquerque, NM 87110',
              '35.0831033940459, -106.61611343660347'
            ],
            mode: TravelMode.walking.toString());
    print(distanceMatrix);
    expect(distanceMatrix, isA<List<OriginDestinationMetrics>>());
  });
}
