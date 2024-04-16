import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:http/http.dart' as http;
import 'places_types.dart';
import 'package:flutter_overpass/flutter_overpass.dart';

/// The controller that manages all the use of places API
///
/// Parameters:
///   - [placesApiKey](String) The API key of the Google Places API.
class PlacesController {
  String placesSummary = '';
  int summaryFlag = 0;
  String responseBody = '';
  Map<String, String>? responseHeaders;
  String placesApiKey;
  static const List<String> defaultTypes = [PlaceType.any];
  bool useGooglePlacesApi;
  bool _methodsSelector;

  PlacesController({required this.placesApiKey, this.useGooglePlacesApi = true})
      : _methodsSelector = useGooglePlacesApi;
  factory PlacesController.overpassPlugin() {
    return PlacesController(
        placesApiKey: 'API_DISABLED', useGooglePlacesApi: false);
  }

  /// Gets the raw output from the Google Places API.
  ///
  /// Parameters:
  ///   - [centerCoord](GeoCoord from package: google_directions_api) The center of the search.
  ///   - [radius](num) The search radius in meters.
  ///   - [types](List<String>) The types of the places to search for.
  ///
  /// Returns:
  ///   - (List<dynamic>) A list of the places found.
  Future<List<dynamic>> fetchNearbyPlaces(GeoCoord centerCoord, num radius,
      {List<String> types = defaultTypes}) async {
    if (!_methodsSelector) {
      throw Exception(
          'Method not available, please use the overpass plugin or create a new instance with a google places API key');
    }
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
    if (!types.contains(PlaceType.any)) {
      requestBodyPrototype['includedTypes'] = types;
    }
    final requestBody = jsonEncode(requestBodyPrototype);
    final response = await http.post(
      Uri.parse(uri),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.businessStatus,places.formattedAddress,places.name,places.types,places.rating,places.nationalPhoneNumber,places.regularOpeningHours',
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

  /// Gets the simplified output from the Google Places API as a comprehensiuve list of maps.
  ///
  /// Parameters:
  ///   - [centerCoord] (GeoCoord from package: google_directions_api) The center of the search.
  ///   - [radius] (num) The search radius in meters.
  ///   - [types] (List<String>) The types of the places to search for.
  ///
  /// Returns:
  ///   - (List<dynamic>) A list of the places found.
  Future<List<dynamic>> simplifyFetchNearbyPlacess(
      GeoCoord centerCoord, num radius,
      {List<String> types = defaultTypes}) async {
    if (!_methodsSelector) {
      throw Exception(
          'Method not available, please use the overpass plugin or create a new instance with a google places API key');
    }
    try {
      final data = await fetchNearbyPlaces(centerCoord, radius, types: types);
      List<dynamic> result = [];
      for (var element in data) {
        result.add({
          'placeId': element['id'],
          'name': element['displayName'] != null
              ? element['displayName']['text']
              : 'unspecified',
          'open_now': (element['regularOpeningHours'] != null &&
                  element['regularOpeningHours']['openNow'] != null)
              ? element['regularOpeningHours']['openNow']
              : 'unspecified',
          'opening_hours': (element['regularOpeningHours'] != null &&
                  element['regularOpeningHours']['weekdayDescriptions'] != null)
              ? element['regularOpeningHours']['weekdayDescriptions']
              : 'unspecified',
          'rating': element['rating'] ?? 'unspecified',
          'business_status': element['businessStatus'] ?? 'unspecified',
          'address': element['formattedAddress'],
          'phone_number': element['nationalPhoneNumber'] ?? 'unspecified',
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

  /// Summarizes the nearby places found in a single string.
  ///
  /// Parameters:
  ///   - [places] (List<dynamic>) The places to summarize.
  ///
  /// Returns:
  ///   - (String) A string with the summary of the places.
  String summaryNerbyPlaces(List<dynamic>? places) {
    if (!_methodsSelector) {
      throw Exception(
          'Method not available, please use the overpass plugin or create a new instance with a google places API key');
    }
    String summary = '';
    if (places == null || places.isEmpty) {
      return 'No places nearby';
    }
    for (var element in places) {
      summary =
          '$summary${element['displayName']['text']}(${element['types'][0]}, ${element['types'][1]}), ';
    }
    return summary;
  }

  /// Fetches and summarizes the nearby places, its a combination of the methods fetchNearbyPlaces and summaryNerbyPlaces.
  ///
  /// Parameters:
  ///   - [centerCoord] (GeoCoord from package: google_directions_api) The center of the search.
  ///   - [radius] (num) The search radius in meters.
  ///   - [types] (List<String>) The types of the places to search for.
  ///
  /// Returns:
  ///   - (String) A string with the summary of the places.
  Future<String> fetchAndSummarizeNearbyPlaces(
      GeoCoord? centerCoord, double radius,
      {List<String> types = defaultTypes}) async {
    if (!_methodsSelector) {
      throw Exception(
          'Method not available, please use the overpass plugin or create a new instance with a google places API key');
    }
    try {
      GeoCoord queryCoord;
      if (centerCoord != null) {
        queryCoord = centerCoord;
      } else {
        return 'Error invalid geoCoord';
      }
      final List<dynamic> nearbyPlaces =
          await fetchNearbyPlaces(queryCoord, radius, types: types);
      final String summary = summaryNerbyPlaces(nearbyPlaces);
      return summary;
    } catch (e) {
      throw Exception('Failed to fetch and summarize nearby places: $e');
    }
  }

  /// This methos fetches the places photos IDs as according to the Google Plces API, you have to get the photo ID of the place before getting the urls
  ///
  /// Parameters:
  ///   - [placeId] (String) The ID of the place to fetch the photos from.
  ///
  /// Returns:
  ///   - (List<dynamic>) A list of the photos found.
  Future<List<dynamic>> fetchPlacePhotosData(String placeId) async {
    if (!_methodsSelector) {
      throw Exception(
          'Method not available, please use the overpass plugin or create a new instance with a google places API key');
    }
    String uri = 'https://places.googleapis.com/v1/places/$placeId';
    Map<String, String> headers = {
      'ContentType': 'application/json',
      'X-Goog-Api-Key': placesApiKey,
      'X-Goog-FieldMask': 'photos'
    };
    final response = await http.get(Uri.parse(uri), headers: headers);
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

  /// This method fetches the photos uris as according to the Google Places API.
  ///
  /// Parameters:
  ///   - [photos] (List<dynamic>) The photos to fetch the urls from, the result from the method fetchPlacePhotosData.
  ///   - [width] (int) The required width of the photo.
  ///   - [height] (int) The height of the photo.
  ///   - [maxOperations] (int) The maximum number of operations to fetch (the number of photos to fetch).
  ///
  /// Returns:
  ///   - (List<dynamic>) A list of the photos uris.
  Future<List<dynamic>> fetchPhotosUris(List<dynamic> photos,
      {int? width, int? height, int? maxOperations}) async {
    if (!_methodsSelector) {
      throw Exception(
          'Method not available, please use the overpass plugin or create a new instance with a google places API key');
    }
    List<dynamic> output = [];
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
          String uri =
              'https://places.googleapis.com/v1/${photo['name']}/media??maxHeightPx=$width&maxWidthPx=$height&key=$placesApiKey';
          final result = await http.get(Uri.parse(uri));
          if (result.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(result.body);
            responseBody = result.body;
            responseHeaders = result.headers;
            if (data.isEmpty) {
              throw Exception(
                  'Failed to fetch photo: ${result.statusCode}: body is empty');
            }
            output.add(data);
          } else {
            throw Exception(
                'Failed to fetch photo: ${result.statusCode}: ${result.body}');
          }
        }
        return output;
      case 1:
        for (var i = 0; i < maxOperations!; i++) {
          String uri =
              'https://places.googleapis.com/v1/${photos[i]['name']}/media?maxHeightPx=$width&maxWidthPx=$height&skipHttpRedirect=true&key=$placesApiKey';
          final result = await http.get(Uri.parse(uri));
          if (result.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(result.body);
            responseBody = result.body;
            responseHeaders = result.headers;
            if (data.isEmpty) {
              throw Exception(
                  'Failed to fetch photo: ${result.statusCode}: body is empty');
            }
            output.add(data);
          } else {
            throw Exception(
                'Failed to fetch photo: ${result.statusCode}: ${result.body}');
          }
        }
        return output;
      default:
        throw Exception('Wrong operation');
    }
  }

  Future<dynamic> overpassSimplifyFetchNearbyPlacess(
      GeoCoord centerCoord, num radius,
      {List<String> types = defaultTypes}) async {
    try {
      final flutterOverpass = FlutterOverpass();
      final nearbyPlaces = await flutterOverpass.getNearbyNodes(
        latitude: centerCoord.latitude,
        longitude: centerCoord.longitude,
        radius: radius.toDouble(),
      );
      return nearbyPlaces;
    } catch (e) {
      throw Exception('Failed to fetch nearby places: $e');
    }
  }
}
