import 'dart:convert';

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

class PhotoCollection {
  List<Map<String, dynamic>> placePhotoUriCollection;
  PhotoCollection({required this.placePhotoUriCollection});
}

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
