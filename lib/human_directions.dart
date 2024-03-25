import 'dart:convert';

import 'package:flutter/material.dart' hide Step;
import 'package:google_directions_api/google_directions_api.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:human_directios/components/llm/models.dart';
import 'package:human_directios/components/llm/system_messages.dart';
import 'package:human_directios/components/llm/tools/tools.dart';
import 'package:human_directios/components/places/places.dart';
import 'package:human_directios/components/llm/supported_languages.dart';
import 'package:human_directios/components/location.dart';
import 'package:human_directios/components/llm/recomendations_parse.dart';

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
  HumanDirectionsLLMSystenMessages systenMessages;
  List<String> nearbyPlacesFrom = [];
  List<String> nearbyPlacesTo = [];
  GeoCoord? currentPosition;
  /* Parameters */
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  String openAIlanguage;
  String prompt;
  String googlelanguage;
  UnitSystem unitSystem;
  TravelMode travelMode;
  double placesRadious;
  String gptModel;
  double gptModelTemperature;

  HumanDirections(
      {required this.openAiApiKey,
      required this.googleDirectionsApiKey,
      this.prompt = '\n',
      this.googlelanguage = 'en',
      this.unitSystem = UnitSystem.metric,
      this.travelMode = TravelMode.walking,
      this.openAIlanguage = OpenAILanguage.en,
      this.placesRadious = 50.0,
      this.gptModel = OpenAiModelsNames.gpt4,
      this.gptModelTemperature = 0.4})
      : nearbyplacesController =
            PlacesController(placesApiKey: googleDirectionsApiKey),
        systenMessages =
            HumanDirectionsLLMSystenMessages(openAIlenguage: openAIlanguage);
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

  Future<NearbyPlacesRecomendationsObject> getNearbyRecommendations(
      String prompt, BuildContext context) async {
    await getCurrentLocation(context);
    return await _gptPromptNearbyPlaces(prompt, currentPosition!)
        .timeout(const Duration(minutes: 2));
  }

  int _fetchDirections(String origin, String destination) {
    DirectionsService directionsService = DirectionsService();
    DirectionsService.init(googleDirectionsApiKey);

    final request = DirectionsRequest(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
        unitSystem: unitSystem,
        language: googlelanguage);

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
    final systemMessage = systenMessages.humanDirectionsSysMsg;

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
        model: gptModel,
        messages: requestMessages,
        temperature: gptModelTemperature,
      );
      humanDirectionsResult = chat.choices[0].message.content?[0].text;

      humanDirectionsFlag = 0;
    } catch (e) {
      humanDirectionsResult = 'Exception: $e';
      humanDirectionsFlag = 2;
    }
  }

  Future<NearbyPlacesRecomendationsObject> _gptPromptNearbyPlaces(
      String prompt, GeoCoord location) async {
    try {
      OpenAI.apiKey = openAiApiKey;
      final systemMessage = systenMessages.recommendationsSysMsg;

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'location(${location.latitude}, ${location.longitude}), $prompt',
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      final requestMessages = [systemMessage, userMessage];

      final tools = HumanDirectionsLLMTools.recommendationTool;
      final chat = await OpenAI.instance.chat.create(
        model: gptModel,
        messages: requestMessages,
        temperature: gptModelTemperature,
        tools: [tools],
      ).timeout(const Duration(seconds: 40));
      final message = chat.choices.first.message;
      if (message.haveToolCalls) {
        final call = message.toolCalls!.first;
        if (call.function.name ==
            HumanDirectionsLLMTools.recommendationTool.function.name) {
          final decodedArgs = jsonDecode(call.function.arguments);

          final latitude = decodedArgs[RecommendationToolArgs.latitude.name];
          final longitude = decodedArgs[RecommendationToolArgs.longitude.name];
          final categories = List<String>.from(
              decodedArgs[RecommendationToolArgs.categories.name]);
          final radius = decodedArgs[RecommendationToolArgs.radius.name];

          final result = await nearbyplacesController
              .simplifyFetchNearbyPlacess(GeoCoord(latitude, longitude), radius,
                  types: categories)
              .timeout(const Duration(seconds: 40));
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
      //final secondChat = await _fetchChat(requestMessages, tools).timeout(const Duration(seconds: 40));
      /*final secondResponseMessage =
          secondChat.choices[0].message.content?[0].text;*/
      final secondChat = OpenAI.instance.chat.createStream(
        model: gptModel,
        messages: requestMessages,
        tools: [tools],
        temperature: gptModelTemperature,
      );

      final List<OpenAIStreamChatCompletionModel> completions =
          await secondChat.toList().timeout(const Duration(minutes: 1));

      String secondResponseMessage = '';

      for (var streamChatCompletion in completions) {
        final content = streamChatCompletion.choices.first.delta.content;
        secondResponseMessage += (content?[0]?.text ?? '');
      }
      if (secondResponseMessage.length > 10) {
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
          photosId.add(await nearbyplacesController
              .fetchPlacePhotosData(element.id)
              .timeout(const Duration(seconds: 40)));
        }
        int i = 0;
        for (var element in photosId) {
          photosRep[i]['uri_collection'] = await nearbyplacesController
              .fetchPhotosUrl(element,
                  width: 400, height: 400, maxOperations: 1)
              .timeout(const Duration(seconds: 40));
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
