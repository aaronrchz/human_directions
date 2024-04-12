import 'dart:convert';
import 'package:http/http.dart' as http;
import 'metrics.dart';

Future<List<OriginDestinationMetrics>> getDistanceMatrix(String apiKey,
    {required List<String> origins,
    required List<String> destinations,
    String units = 'metric',
    String mode = DistanceMatrixTravelModes.walking}) async {
  try {
    print(mode);
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${destinations.join('|')}&mode=$mode&origins=${origins.join('|')}&units=$units&key=$apiKey'),
    );
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      if (body['status'] != 'OK') {
        throw Exception('Request error: ${body['status']}');
      }
      List<OriginDestinationMetrics> metrics = [];
      int originsCounter = 0;
      for (var originAddresses in body['origin_addresses']) {
        metrics.add(OriginDestinationMetrics(
            originAddress: originAddresses, destinationsMetrics: []));
        originsCounter++;
      }
      originsCounter = 0;
      for (var row in body['rows']) {
        for (var element in row['elements']) {
          metrics[originsCounter].destinationsMetrics.add(
                DestinationMetric(
                  destinationAddress: body['destination_addresses']
                      [originsCounter],
                  metric: Metric(
                    distance: Distance(
                        text: element['distance']['text'],
                        value: element['distance']['value']),
                    duration: Time(
                        text: element['duration']['text'],
                        value: element['duration']['value']),
                  ),
                ),
              );
        }
        originsCounter++;
      }
      return metrics;
    } else {
      throw Exception('HTTP Error: ${response.statusCode} , ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching distance matrix: $e');
  }
}

class DistanceMatrixTravelModes {
  static const String walking = 'walking';
  static const String driving = 'driving';
  static const String transit = 'transit';
  static const String bicycling = 'bicycling';
}

class Metric {
  Distance distance;
  Time duration;

  Metric({required this.distance, required this.duration});
}

class DestinationMetric {
  final String destinationAddress;
  final Metric metric;
  DestinationMetric({required this.destinationAddress, required this.metric});
}

class OriginDestinationMetrics {
  final String originAddress;
  final List<DestinationMetric> destinationsMetrics;
  OriginDestinationMetrics(
      {required this.originAddress, required this.destinationsMetrics});
}
