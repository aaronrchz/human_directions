import 'dart:convert';

class Recommendation {
  final String name;
  final String address;
  final String rating;
  final String description;
  final String openNow;
  final String openingHours;

  Recommendation({
    required this.name,
    required this.address,
    required this.rating,
    required this.description,
    required this.openNow,
    required this.openingHours,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toString(),
      description: json['description'],
      openNow: json['open_now'].toString(),
      openingHours: json['opening_hours']
    );
  }
}

class NearbyPlacesRecomendationsObject {
  List<Recommendation>? recommendations;
  String? startMessage;
  String? closingMessage;
  bool hasError;
  String? errorMessage; 

  NearbyPlacesRecomendationsObject(
      {required this.startMessage,
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
  factory NearbyPlacesRecomendationsObject.fromError(Object e){
    return NearbyPlacesRecomendationsObject(
      startMessage: null,
      recommendations: null,
      closingMessage: null,
      errorMessage:  e.toString(),
      hasError: true,
    );
  }

}
