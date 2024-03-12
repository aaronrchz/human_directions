import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:http/http.dart' as http;
import 'package:human_directios/componets/places_types.dart';

class PlacesController {
  String placesSummary = '';
  int summaryFlag = 0;
  String responseBody = '';
  Map<String, String>? responseHeaders;
  String placesApiKey;

  PlacesController({required this.placesApiKey});

  Future<List<dynamic>> fetchNearbyPlaces(GeoCoord centerCoord, num radius,
      {String type = PlaceType.any}) async {
    String apiKey = placesApiKey;
    const uri = 'https://places.googleapis.com/v1/places:searchNearby';
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
    if (type != PlaceType.any) {
      requestBodyPrototype['includedTypes'] = [type];
    }
    final requestBody = jsonEncode(requestBodyPrototype);
    final response = await http.post(
      Uri.parse(uri),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.Id,places.displayName,places.businessStatus,places.formattedAddress,places.name,places.types,places.rating,places.nationalPhoneNumber,places.regularOpeningHours,places.photos',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      responseBody = response.body;
      responseHeaders = response.headers;
      if (data.isEmpty) {
        return [];
      }
      return data['places'];
    } else {
      throw Exception(
          'Failed to load nearby places: ${response.statusCode}: ${response.body}');
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
          'placeId': element['placeId'],
          'name': element['displayName']['text'],
          'open_now': element['regularOpeningHours']['openNow'],
          'opening_hours': element['regularOpeningHours']
              ['weekdayDescriptions'],
          'rating': element['rating'],
          'business_status': element['businessStatus'],
          'address': element['formattedAddress'],
          'phone_number': element['nationalPhoneNumber'],
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
      summary =
          '$summary${element['displayName']['text']}(${element['types']}), ';
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

/*Work in progress */
  Future<List<dynamic>> fetchPlacePhotosData(String place) async {
    String uri = 'https://places.googleapis.com/v1/places/$place';
    Map<String, String> headers = {
      'ContentType': 'application/json',
      'X-Goog-Api-Key': placesApiKey,
      'X-Goog-FieldMask': 'places.photos'
    };
    final response = await http.post(Uri.parse(uri), headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      responseBody = response.body;
      responseHeaders = response.headers;
      if (data.isEmpty) {
        return [];
      }
      return data['photos'];
    } else {
      throw Exception(
          'Failed to fetch places photos: ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchPhotosUrl(List<dynamic> photos,
      {int? width, int? height, int? maxOperations}) async {
    int opCase = 0;
    if (maxOperations != null) {
      if (maxOperations > photos.length) {
        throw Exception(
            "Number of operations exceeds the lenght of the given list");
      } else {
        opCase = 1;
      }
    } else {
      opCase = 0;
    }
    switch (opCase) {
      case 0:
        for (var photo in photos) {
          String uri = 'https://places.googleapis.com/v1/${photo['name']}';
          String key = '&key=$placesApiKey';
        }
        break;
      case 1:
        break;
      default:
        break;
    }
    return [];
  }
}

class PlacePhotosDimentios {
  final int width;
  final int height;
  PlacePhotosDimentios({required this.width, required this.height});
  factory PlacePhotosDimentios.fromMap(Map<String, dynamic> map) {
    return PlacePhotosDimentios(width: map['width'], height: map['height']);
  }
}
