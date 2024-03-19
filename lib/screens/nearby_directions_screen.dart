import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:human_directios/componets/llm/recomendations_parse.dart';
import 'package:human_directios/componets/llm/supported_lenguages.dart';
import 'package:human_directios/human_directions.dart';

class RequestDNearbyPlacesScreen extends StatefulWidget {
  const RequestDNearbyPlacesScreen(
      {required this.googleDirectionsApiKey,
      required this.openAiApiKey,
      required this.func,
      required this.onBack,
      super.key});
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  final void Function(String, String) func;
  final void Function() onBack;
  @override
  State<RequestDNearbyPlacesScreen> createState() =>
      _RequestDNearbyPlacesScreen();
}

class _RequestDNearbyPlacesScreen extends State<RequestDNearbyPlacesScreen> {
  late HumanDirections directionsController;
  final TextEditingController _textEditingController =
      TextEditingController(text: 'donde hay un bar?');
  late Future<NearbyPlacesRecomendationsObject?> _futureResult;

  Future<NearbyPlacesRecomendationsObject?> _handleSubmit() async {
    directionsController = HumanDirections(
        openAiApiKey: widget.openAiApiKey,
        googleDirectionsApiKey: widget.googleDirectionsApiKey,
        travelMode: TravelMode.walking,
        unitSystem: UnitSystem.metric,
        openAIlenguage: OpenAILenguage.es);
    String input = _textEditingController.text;
    return await directionsController
        .getNearbyRecommendations(input, context)
        .timeout(const Duration(minutes: 10));
  }

  @override
  void initState() {
    super.initState();
    _futureResult = Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Recomendacion de lugares cercanos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  labelText: 'Solicitud',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureResult = _handleSubmit();
                  });
                },
                child: const Text('Solicitar'),
              ),
              FutureBuilder<NearbyPlacesRecomendationsObject?>(
                future: _futureResult,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Obteniendo recomendaciones\nPor favor espere...")
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    NearbyPlacesRecomendationsObject data = snapshot.data!;
                    if (data.hasError) {
                      print(data.errorMessage);
                      return Text(data.errorMessage!);
                    }
                    if (data.recommendations != null) {
                      return Column(
                        children: [
                          Text(data.startMessage ?? 'result:'),
                          SingleChildScrollView(
                            child: SizedBox(
                              height:
                                  400, // Define una altura adecuada según tus necesidades
                              child: ListView(
                                padding: const EdgeInsets.all(8),
                                children: [
                                  ...data.recommendations!.asMap().entries.map(
                                    (entry) {
                                      final index = entry.key;
                                      final e = entry.value;
                                      return ExpansionTile(
                                        title: Text(e.name),
                                        subtitle: Column(
                                          children: [
                                            Text(e.description),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.star_rate_rounded),
                                                Text(e.rating),
                                              ],
                                            ),
                                          ],
                                        ),
                                        children: [
                                          Text('Abierto: ${e.openingHours}'),
                                          Text(
                                              'Numero de telefono: ${e.phoneNumber}'),
                                          Image.network(data
                                                      .recomendationPhotos!
                                                      .placePhotoUriCollection[
                                                  index]['uri_collection'][0]
                                              ['photoUri']),
                                          TextButton(
                                            onPressed: () {
                                              widget.func(
                                                  ('${directionsController.currentPosition!.latitude}, ${directionsController.currentPosition!.longitude}'),
                                                  e.address);
                                            },
                                            child: const Text('¡Quiero ir!'),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(data.closingMessage ?? 'end of result.'),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Text(data.startMessage!),
                          Text(data.closingMessage!),
                        ],
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
