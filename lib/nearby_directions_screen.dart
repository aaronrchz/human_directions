import 'package:flutter/material.dart';
import 'package:human_directios/human_directions.dart';

class RequestDNearbyPlacesScreen extends StatefulWidget {
  const RequestDNearbyPlacesScreen(
      {required this.googleDirectionsApiKey,
      required this.openAiApiKey,
      super.key});
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  @override
  State<RequestDNearbyPlacesScreen> createState() =>
      _RequestDNearbyPlacesScreen();
}

class _RequestDNearbyPlacesScreen extends State<RequestDNearbyPlacesScreen> {
  late HumanDirections directionsController;
  final TextEditingController _textEditingController = TextEditingController();
  late Future<String?> _futureResult;

  Future<String?> _handleSubmit() async {
    directionsController = HumanDirections(
        openAiApiKey: widget.openAiApiKey,
        googleDirectionsApiKey: widget.googleDirectionsApiKey);
    String input = _textEditingController.text;
    await directionsController.getCurrentLocation(context);
    return await directionsController.gptPromptNearbyPlaces(
        input, directionsController.currentPosition!);
  }

  @override
  void initState() {
    super.initState();
    _futureResult = Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask for places recomandations nearby')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const Text(
                'Preguinta por recomendaciones e.j. ¿Donde puedo comer sushi por aqui?'),
            TextField(controller: _textEditingController),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureResult = _handleSubmit();
                });
              },
              child: const Text('Solicitar'),
            ),
            FutureBuilder<String?>(
              future: _futureResult,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
