import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:human_directios/componets/places_types.dart';

class PlacesTest extends StatelessWidget {
  const PlacesTest({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Google Places API Example')),
        body: Center(
          child: FutureBuilder(
            future: PlacesController().fetchNearbyPlaces(
                const GeoCoord(21.09493179360217, -101.65238872573657), 50.0),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<dynamic>? places = snapshot.data;
                return ListView.builder(
                  itemCount: places?.length,
                  itemBuilder: (context, index) {
                    PlacesController().summaryNerbyPlaces(places);
                    return ListTile(
                      title: Text(places?[index]['name']),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class PlacesController{
String placesSummary = '';
int summaryFlag = 0;

Future<List<dynamic>> fetchNearbyPlaces(GeoCoord centerCoord, double radius,
    {String type = PlaceType.any}) async {
  String apiKey = dotenv.env['GOOGLE_DIRECTIOS_API_KEY'] ?? 'NO SUCH KEY';
  String location = '${centerCoord.latitude},${centerCoord.longitude}';
  String radiusString = radius.toString();
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=$location&radius=$radiusString&type=$type'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['results'];
  } else {
    throw Exception('Failed to load nearby places');
  }
}

String summaryNerbyPlaces(List<dynamic>? places) {
  String summary = '';
  if (places == null || places.isEmpty) {
    return 'No places nearby';
  }
  for (var element in places) {
    summary = '$summary${element['name']}(${element['types']}), ';
  }
  return summary;
}

Future<String> fetchAndSummarizeNearbyPlaces(
    GeoCoord? centerCoord, double radius,
    {String type = PlaceType.any}) async {
  try {
    GeoCoord queryCoord;
    if(centerCoord != null){
      queryCoord = centerCoord;
    }else{
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