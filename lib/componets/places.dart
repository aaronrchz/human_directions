import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/componets/places_types.dart';

class PlacesController {
  String placesSummary = '';
  int summaryFlag = 0;
  String responseBody = '';
  Map<String, String>? responseHeaders;

  Future<List<dynamic>> fetchNearbyPlaces(GeoCoord centerCoord, num radius,
      {String type = PlaceType.any}) async {
    String apiKey = dotenv.env['GOOGLE_DIRECTIOS_API_KEY'] ?? 'NO SUCH KEY';
    const url = 'https://places.googleapis.com/v1/places:searchNearby';
    final requestBodyPrototype = {
      "maxResultCount": 20,
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": centerCoord.latitude,
            "longitude": centerCoord.longitude
          },
          "radius": radius
        }
      }
    };
    if(type != PlaceType.any){
      requestBodyPrototype['includedTypes'] = [type];
    }
    final requestBody = jsonEncode(requestBodyPrototype);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.displayName,places.businessStatus,places.formattedAddress,places.name,places.types,places.rating,places.nationalPhoneNumber,places.regularOpeningHours',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      responseBody = response.body;
      responseHeaders = response.headers;
      if(data.isEmpty){
        return [];
      }
      return data['places'];
    } else {
      throw Exception('Failed to load nearby places: ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> simplifyFetchNearbyPlacess(
      GeoCoord centerCoord, num radius,
      {String type = PlaceType.any}) async {
    try {
      final data = await fetchNearbyPlaces(centerCoord, radius, type: type);
      List<dynamic> result = [];
      for (var element in data) {
        result.add({
          'name': element['displayName']['text'],
          'open_now': element['regularOpeningHours']['openNow'],
          'opening_hours': element['regularOpeningHours']
              ['weekdayDescriptions'],
          'rating': element['rating'],
          'business_status': element['businessStatus'],
          'address': element['formattedAddress'],
          'phone_number': element['nationalPhoneNumber']
        });
      }
      return result;
    } catch (e) {
      return [
        {
          'message': 'An exception has ocurred while getting nearby placecs',
          'exception': e,
        }
      ];
    }
  }

  String summaryNerbyPlaces(List<dynamic>? places) {
    String summary = '';
    if (places == null || places.isEmpty) {
      return 'No places nearby';
    }
    for (var element in places) {
      summary = '$summary${element['displayName']['text']}(${element['types']}), ';
    }
    return summary;
  }

  Future<String> fetchAndSummarizeNearbyPlaces(
      GeoCoord? centerCoord, double radius,
      {String type = PlaceType.any}) async {
    try {
      GeoCoord queryCoord;
      if (centerCoord != null) {
        queryCoord = centerCoord;
      } else {
        return 'Error invalid geoCoord';
      }
      final List<dynamic> nearbyPlaces =
          await fetchNearbyPlaces(queryCoord, radius, type: type);
      final String summary = summaryNerbyPlaces(nearbyPlaces);
      return summary;
    } catch (e) {
      throw Exception('Failed to fetch and summarize nearby places: $e');
    }
  }
}
