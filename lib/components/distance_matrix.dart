import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getDistanceMatrix(String apiKey,
    {required List<String> origins,
    required List<String> destinations,
    String units = 'metric',
    String mode = 'walking'}) async {
  final response = await http.get(
    Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${destinations.join('|')}&mode=$mode&origins=${origins.join('|')}&units=$units&key=$apiKey'),
  );
  var body = json.decode(response.body);
  // var data = json.decode(body['rows']);
  return body;
}

class Metric {
  final num distanceValue;
  final String distanceText;
  final num durationValue;
  final String durationText;
  Metric(
      {required this.distanceValue,
      required this.distanceText,
      required this.durationValue,
      required this.durationText});
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
