//import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_overpass/flutter_overpass.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:human_directions/components/distance_matrix.dart';
import 'package:human_directions/components/llm/recomendations_parse.dart';
import 'package:human_directions/human_directions.dart';
import 'package:human_directions/components/places/places.dart';

//import 'package:human_directions/example/showcase_app/human_directions_app.dart';
void main() async {
  await dotenv.load(fileName: '.env');
  String googleCloudApiTestkey = dotenv.env['GOOGLE_DIRECTIOS_API_KEY']!;
  String openAiApiTestKey = dotenv.env['OPENAI_API_KEY']!;
  test('test Distance Matrix', () async {
    final distanceMatrix = await getDistanceMatrix(googleCloudApiTestkey,
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
  test('test nearbyRecomendations', () async {
    String openAiApiKey = openAiApiTestKey;
    String googleDirectionsApiKey = googleCloudApiTestkey;
    final HumanDirections controller = HumanDirections(
        openAiApiKey: openAiApiKey,
        googleDirectionsApiKey: googleDirectionsApiKey);
    const String prompt = 'Where can i get a drink?';
    const bool fetchPhotos =
        false; //set to true if you want to fetch the photos for the places
    NearbyPlacesRecomendationsObject recommendations =
        await controller.getRecommendations(
            prompt, const GeoCoord(35.06609963151214, -106.5336236826646),
            fetchPhotos: fetchPhotos);

    if (recommendations.hasError) {
      print(recommendations.errorMessage);
      return;
    }
    print(recommendations.startMessage);
    for (var recommendation in recommendations.recommendations!) {
      print(recommendation.name);
      print(recommendation.address);
      print(recommendation.description);
      print(recommendation.openingHours);
      print(recommendation.rating);
      print(recommendation.phoneNumber);
      print(recommendation.distance.text);
      print(recommendation.duration.text);
    }
    print(recommendations.closingMessage);
    expect(recommendations, isA<NearbyPlacesRecomendationsObject>());
    expect(recommendations.hasError, isFalse);
  });
  test('test Overrpass nearbyRecomendations', () async {
    PlacesController controller = PlacesController.overpassPluginOnly();
    var result = await controller.overpassSimplifyFetchNearbyPlacess(
        const GeoCoord(35.06624013447273, -106.53272246040005), 500);
    if (result.isEmpty) {
      return;
    }
    for (var element in result) {
      print('id: ${element.id}');
      print('name: ${element.tags?.name}');
      print('openingHours: ${element.tags?.openingHours}');
      print('beauty: ${element.tags?.beauty}');
      print('amenity: ${element.tags?.amenity}');
      print(
          'Address: ${element.tags?.addrStreet} ${element.tags?.addrHousenumber} ${element.tags?.addrCity} ${element.tags?.addrPostcode}');
      print('Location: ${element.lat}, ${element.lon}');
      print('openingHours: ${element.tags?.openingHours}');
      print('website: ${element.tags?.website}');
    }
    expect(result, isA<List<Element>>());
    expect(result, isNotEmpty);
  });
}
