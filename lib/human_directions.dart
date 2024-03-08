import 'dart:convert';

import 'package:flutter/material.dart' hide Step;
import 'package:google_directions_api/google_directions_api.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:human_directios/componets/places.dart';
import 'package:human_directios/componets/places_types.dart';
import 'package:human_directios/componets/supported_lenguages.dart';
import 'package:human_directios/componets/location.dart';

class HumanDirections {
  /* flags */
  int resultFlag = 1;
  int humanDirectionsFlag = 1;
  /*Output Data */
  Distance resolvedDistance = Distance();
  Time resolvedTime = Time();
  List<Step>? steps = [];
  String requestResult = 'awaiting';
  String? humanDirectionsResult = '';
  PlacesController nearbyplacesController = PlacesController();
  List<String> nearbyPlacesFrom = [];
  List<String> nearbyPlacesTo = [];
  GeoCoord? currentPosition;
  /* Parameters */
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  String openAIlenguage;
  String prompt;
  String googlelenguage;
  UnitSystem unitSystem;
  TravelMode travelMode;
  double placesRadious;

  HumanDirections(
      {required this.openAiApiKey,
      required this.googleDirectionsApiKey,
      this.prompt = '\n',
      this.googlelenguage = 'en',
      this.unitSystem = UnitSystem.metric,
      this.travelMode = TravelMode.walking,
      this.openAIlenguage = OpenAILenguage.en,
      this.placesRadious = 10.0});
  /* getters */
  List<Step>? get directionsStepsList => steps;
  String get directionsRequestResult => requestResult;
  int get fetchResultFlag => resultFlag;
  int get fetchHumanDirectionsFlag => humanDirectionsFlag;
  String? get updateFetchHumanDirections => humanDirectionsResult;
  /*Methods */
  int fetchHumanDirections(String origin, String destination,
      {double placesRadious = 50.0}) {
    _fetchDirections(origin, destination, placesRadious: placesRadious);
    return 0;
  }

  int fetchHumanDirectionsFromLocation(String destination,
      {double placesRadious = 50.0}) {
    if (currentPosition == null) {
      return 1;
    }
    _fetchDirections(
        '${currentPosition?.latitude},${currentPosition?.longitude}',
        destination,
        placesRadious: placesRadious);
    return 0;
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    currentPosition = await GeoLocatorHandler().getLocation(context);
  }

  int _fetchDirections(String origin, String destination,
      {double placesRadious = 50.0}) {
    DirectionsService directionsService = DirectionsService();
    DirectionsService.init(googleDirectionsApiKey);

    final request = DirectionsRequest(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
        unitSystem: unitSystem,
        language: googlelenguage);

    directionsService.route(request,
        (DirectionsResult response, DirectionsStatus? status) {
      if (status == DirectionsStatus.ok) {
        resolvedDistance.text = response.routes![0].legs![0].distance?.text;
        resolvedTime.text = response.routes![0].legs![0].duration?.text;
        steps = response.routes![0].legs![0].steps;
        requestResult = 'OK';
        _buildAndPost();
      } else {
        resultFlag = 2;
        requestResult = 'Error: $status : ${response.errorMessage}';
      }
    });
    return resultFlag;
  }

  Future<void> _gptPrompt(String prompt) async {
    OpenAI.apiKey = openAiApiKey;
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Convert this instruction set to a more human-friendly format. 
          Specify when mentioning a street, avenue, etc.
          Be extra friendly.
          Always use the given nearby places to better guide the user.
          If there is not an instruction set, just say 'Ooops! it seems there are not valid instructions.'
          Answer the user in $openAIlenguage. 
          """,
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    // the user message that will be sent to the request.
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );
    final requestMessages = [
      systemMessage,
      userMessage,
    ];
    try {
      final chat = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: requestMessages,
      );
      humanDirectionsResult = chat.choices[0].message.content?[0].text;

      humanDirectionsFlag = 0;
    } catch (e) {
      humanDirectionsResult = 'Exception: $e';
      humanDirectionsFlag = 2;
    }
  }

  Future<void> gptPromptNearbyPlaces(String prompt, GeoCoord location) async {
    try {
      OpenAI.apiKey = openAiApiKey;
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
          The user will give thier location and ask for recommendations about were to g
          o in the following text, please extract and deliverone of the following categories:
          getegories: $placesTypesList
          answer the user in: $openAIlenguage.
          """,
          ),
        ],
        role: OpenAIChatMessageRole.assistant,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'location(${location.latitude}, ${location.longitude}), $prompt',
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      final requestMessages = [systemMessage, userMessage];

      final tools = OpenAIToolModel(
        type: 'function',
        function: OpenAIFunctionModel.withParameters(
          name: 'fetchNearbyPlaces',
          description: 'obtain nearby places',
          parameters: [
            OpenAIFunctionProperty.number(
                name: 'latitude',
                description: 'the user location latitude value'),
            OpenAIFunctionProperty.number(
                name: 'longitude',
                description: 'the user location longitude value'),
            OpenAIFunctionProperty.string(
                name: 'category',
                description: 'Place category, e.g. bar, library',
                enumValues: placesTypesList),
            OpenAIFunctionProperty.number(
                name: 'radius',
                description:
                    'radius in meters around the user location where the places are going to be looked up to'),
          ],
        ),
      );
      final chat = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: requestMessages,
        tools: [tools],
      );
      final message = chat.choices.first.message;
      if (message.haveToolCalls) {
        final call = message.toolCalls!.first;
        if (call.function.name == 'fetchNearbyPlaces') {
          final decodedArgs = jsonDecode(call.function.arguments);

          final latitude = decodedArgs['latitude'];
          final longitude = decodedArgs['longitude'];
          final category = decodedArgs['category'];
          final radius = decodedArgs['radius'];

          final result = await nearbyplacesController.fetchNearbyPlaces(
              GeoCoord(latitude, longitude), radius,
              type: category);
          requestMessages.add(message);
          requestMessages.add(OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.function,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text('Results: $result')
            ],
            toolCalls: [call],
          ));
        }
      }
      final secondChat = await OpenAI.instance.chat
          .create(model: "gpt-4", messages: requestMessages, tools: [tools]);

      final secondResponseMessage =
          secondChat.choices[0].message.content?[0].text;
      print(secondResponseMessage);
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _getAllNearbyPlaces() async {
    for (int i = 0; i < (steps?.length ?? 0); i++) {
      nearbyPlacesFrom.add(
          await nearbyplacesController.fetchAndSummarizeNearbyPlaces(
              steps?[i].startLocation, placesRadious));
    }
    for (int i = 0; i < (steps?.length ?? 0); i++) {
      nearbyPlacesTo.add(await nearbyplacesController
          .fetchAndSummarizeNearbyPlaces(steps?[i].endLocation, placesRadious));
    }
  }

  Future<void> _buildAndPost() async {
    await _getAllNearbyPlaces();
    for (int i = 0; i < (steps?.length ?? 0); i++) {
      String currentDir =
          '${i + 1} - From: ${steps?[i].startLocation.toString()} (Nearby Places: ${nearbyPlacesFrom[i]} ),to: ${steps?[i].endLocation.toString()} (Nearby Places: ${nearbyPlacesTo[i]}), Instructions: ${steps?[i].instructions},Distance:${steps?[i].distance?.text}  ,Time:${steps?[i].duration?.text}  , Maneuver: ${steps?[i].maneuver} \n';
      prompt = prompt + currentDir;
    }
    _gptPrompt(prompt);
    resultFlag = 0;
  }
}

class Distance {
  String? text;
  num? value;
}

class Time {
  String? text;
  num? value;
}
