import 'dart:convert';

///Class that represennts one single place recommendation
class Recommendation {
  final String id;
  final String name;
  final String address;
  final String rating;
  final String description;
  final String openingHours;
  final String phoneNumber;

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
    return Recommendation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toString(),
      description: json['description'],
      //openNow: json['open_now'].toString(),
      openingHours: json['opening_hours'],
      phoneNumber: json['phone_number'],
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
