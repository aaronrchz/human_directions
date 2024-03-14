import 'dart:convert';

import 'package:flutter/material.dart' hide Step;
import 'package:google_directions_api/google_directions_api.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:human_directios/componets/places.dart';
import 'package:human_directios/componets/places_types.dart';
import 'package:human_directios/componets/supported_lenguages.dart';
import 'package:human_directios/componets/location.dart';
import 'package:human_directios/componets/recomendations_parse.dart';

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
  PlacesController nearbyplacesController;
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
      this.placesRadious = 50.0})
      : nearbyplacesController =
            PlacesController(placesApiKey: googleDirectionsApiKey);
  /* getters */
  List<Step>? get directionsStepsList => steps;
  String get directionsRequestResult => requestResult;
  int get fetchResultFlag => resultFlag;
  int get fetchHumanDirectionsFlag => humanDirectionsFlag;
  String? get updateFetchHumanDirections => humanDirectionsResult;
  /*Methods */
  int fetchHumanDirections(String origin, String destination) {
    _fetchDirections(origin, destination);
    return 0;
  }

  int fetchHumanDirectionsFromLocation(String destination) {
    if (currentPosition == null) {
      return 1;
    }
    _fetchDirections(
        '${currentPosition?.latitude},${currentPosition?.longitude}',
        destination);
    return 0;
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    currentPosition = await GeoLocatorHandler().getLocation(context);
  }

  int _fetchDirections(String origin, String destination) {
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

  Future<NearbyPlacesRecomendationsObject> gptPromptNearbyPlaces(
      String prompt, GeoCoord location) async {
    try {
      OpenAI.apiKey = openAiApiKey;
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
          The user will give thier location and ask for recommendations about were to go
          in the following text, please extract and deliver one of the following categories:
          getegories: $placesTypesList
          however if the place is not open at the moment do not recommend it or mark it as closed.
          Avoid using Links.
          The output mus be a map with the following format and none filed must be null:
          {
            'start_message': 'any messsage to give contex to the user',
            'recommendations' : [{
              'id': 'place id given by the api'
              'name': 'String, Place name',
              'address': 'String, Place Address',
              'rating': 'String, Place rating',
              'description': 'String, a shrot polace description based on place type, and name',
              'opening_hours': 'String, Place Opening hours' ,
              'phone_numer': 'String, place phone number'
            }],
            'closing_message': 'any messsage to give contex to the user' 
          }
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
          description: 'obtain nearby places, all parameters are required',
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

          final result = await nearbyplacesController
              .simplifyFetchNearbyPlacess(GeoCoord(latitude, longitude), radius,
                  type: category);
          requestMessages.add(message);
          requestMessages.add(RequestFunctionMessage(
            role: OpenAIChatMessageRole.tool,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  'Results: $result')
            ],
            toolCallId: call.id!,
          ));
        }
      }
      final secondChat = await OpenAI.instance.chat
          .create(model: "gpt-4", messages: requestMessages, tools: [tools]);

      final secondResponseMessage =
          secondChat.choices[0].message.content?[0].text;
      if (secondResponseMessage != null) {
        final output =
            NearbyPlacesRecomendationsObject.fromString(secondResponseMessage);
        final List<Map<String, dynamic>> photosRep = [];
        for (var element in output.recommendations!) {
          photosRep.add({
            'id': element.id,
            'uri_collection': null,
          });
        }
        final List<List<dynamic>> photosId = [];
        for (var element in output.recommendations!) {
          photosId.add(
              await nearbyplacesController.fetchPlacePhotosData(element.id));
        }
        int i = 0;
        for (var element in photosId) {
          photosRep[i]['uri_collection'] =
              await nearbyplacesController.fetchPhotosUrl(element,
                  width: 400, height: 400, maxOperations: 1);
          i++;
        }
        output.recomendationPhotos =
            PhotoCollection(placePhotoUriCollection: photosRep);
        return output;
      } else {
        return NearbyPlacesRecomendationsObject.fromError(
            Exception('LLM response is empty'));
      }
    } catch (e) {
      return NearbyPlacesRecomendationsObject.fromError(e);
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
