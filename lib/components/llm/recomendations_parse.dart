import 'dart:convert';
import '../metrics.dart';

///Class that represennts one single place recommendation
class Recommendation {
  final String id;
  final String name;
  final String address;
  final String rating;
  final String description;
  final String openingHours;
  final String phoneNumber;
  Distance distance = Distance(text: 'unknown', value: 0);
  Time duration = Time(text: 'unknown', value: 0);

  Recommendation({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.description,
    required this.openingHours,
    required this.phoneNumber,
  });

  ///Factory method to create a Recommendation object from the json map provided by the LLM.
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    var openingHoursList = json['opening_hours'] as List<dynamic>?;
    String openingHoursConcatenated = openingHoursList != null
        ? openingHoursList.map((e) => e.toString()).join(', ')
        : 'No opening hours available';
    return Recommendation(
      id: json['id'] ?? json['placeId'],
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toString(),
      description: json['description'] ?? 'place description not found',
      openingHours: openingHoursConcatenated,
      phoneNumber: json['phone_number'] ??
          'Phone number not available', // Using null-coalescing operator for phoneNumber
    );
  }
  factory Recommendation.fromJsonWithOussideDesc(
      Map<String, dynamic> json, String description) {
    var openingHoursList = json['opening_hours'] as List<dynamic>?;
    String openingHoursConcatenated = openingHoursList != null
        ? openingHoursList.map((e) => e.toString()).join(', ')
        : 'No opening hours available';
    return Recommendation(
      id: json['id'] ?? json['placeId'],
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toString(),
      description: description,
      openingHours: openingHoursConcatenated,
      phoneNumber: json['phone_number'] ??
          'Phone number not available', // Using null-coalescing operator for phoneNumber
    );
  }
}

///Class that represennts a collection of photos for a given place.
class PhotoCollection {
  List<Map<String, dynamic>> placePhotoUriCollection;
  PhotoCollection({required this.placePhotoUriCollection});
}

/// Class that represents the output from the recommendatios of the llm
class NearbyPlacesRecomendationsObject {
  List<Recommendation>? recommendations;
  PhotoCollection? recomendationPhotos;
  String? startMessage;
  String? closingMessage;
  bool hasError;
  String? errorMessage;
  String? processTime;

  NearbyPlacesRecomendationsObject({
    required this.startMessage,
    required this.recommendations,
    required this.closingMessage,
    required this.errorMessage,
    required this.hasError,
  });

  /// Factory method that parses the raw message from the LLM and returns a NearbyPlacesRecomendationsObject object.
  factory NearbyPlacesRecomendationsObject.fromString(String rawData) {
    Map<String, dynamic> data = jsonDecode(rawData);

    return NearbyPlacesRecomendationsObject(
      startMessage: data['start_message'],
      recommendations: (data['recommendations'] as List)
          .map((item) => Recommendation.fromJson(item))
          .toList(),
      closingMessage: data['closing_message'],
      errorMessage: null,
      hasError: false,
    );
  }

  ///Factory method that parses the raw message from the LLM that references only the places ids and returns a NearbyPlacesRecomendationsObject object.
  factory NearbyPlacesRecomendationsObject.fromStringWPIDO(
      String rawData, List<dynamic> placesSearchResult) {
    Map<String, dynamic> data = jsonDecode(rawData);
    List<Recommendation> recommendations = [];
    List<dynamic> idList = data['recommendations'];
    for (var idItem in idList) {
      var found = placesSearchResult.firstWhere(
        (place) => place['placeId'] == idItem['id'],
        orElse: () => null,
      );
      if (found != null) {
        recommendations.add(Recommendation.fromJsonWithOussideDesc(
            found, idItem['description']));
      }
    }
    return NearbyPlacesRecomendationsObject(
      startMessage: data['start_message'],
      closingMessage: data['closing_message'],
      recommendations: recommendations,
      errorMessage: null,
      hasError: false,
    );
  }

  /// Factory Method that builds an output when there is an error.
  factory NearbyPlacesRecomendationsObject.fromError(Object e) {
    return NearbyPlacesRecomendationsObject(
      startMessage: null,
      recommendations: null,
      closingMessage: null,
      errorMessage: e.toString(),
      hasError: true,
    );
  }
}
