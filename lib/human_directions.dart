import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide Step;
import 'package:google_directions_api/google_directions_api.dart'
    hide Distance, Time;
import 'package:dart_openai/dart_openai.dart';
import 'package:human_directions/components/metrics.dart';
import 'components/llm/models.dart';
import 'components/llm/system_messages.dart';
import 'components/llm/tools/tools.dart';
import 'components/places/places.dart';
import 'components/llm/supported_languages.dart';
import 'components/location.dart';
import 'components/llm/recomendations_parse.dart';

/// Main class for the human directions package.
///
/// This class provides functionality for fetching human directions based on specified origin and destination,
/// as well as handling nearby places recommendations and current location retrieval.
///
/// Parameters:
///   - Required:
///     - openAiApiKey: (String) OpenAI API key to access the AI model.
///     - googleDirectionsApiKey: (String) Google Cloud key with access to Directions and Places (new) API to fetch directions
///           and places recommendations.
///   - Optional:
///     - googlelanguage: (String, Default value: 'en') the chosen language code for the Google Directions output
///            you can find all the languages at https://developers.google.com/maps/faq#languagesupport However, it is strongly
///            recommended to keep the language as English, as this does not affect 'human directions' and all the system messages for the AI are in English
///     - unitSystem: (google_direction_api package UnitSystem, Default value: UnitSystem.metric) the unit system used for
///             Direction API to measure the distances and to give the instructions.
///     - travelMode: (google_direction_api package TravelMode, Default value: TravelMode.walking): The used travel mode to get directions.
///     - openAIlanguage: (String, Default value: OpenAILanguage.en) the language in which the AI will communicate with the user
///             there's a class that's part of this package that contains all the supported languages to March 13, 2024:
///             package:human_directions/components/llm/supported_languages.dart
///     - placesRadius: (double, Default value: 50.0) this value represents the dimension of the radius to fetch places for
///             the directions, as they are used to better give better references for each step, this does not affect the
///             recommendations, as that radius is chosen by the AI
///     - gptModel: (String, Default value: OpenAiModelsNames.gpt4) this is the name of the used AI model, there's a class
///             that contains all the model names up to March 13, 2024: package:human_directions/components/llm/models.dart
///             however, as for previous tests, GPT-4 is considered to be the best fit.
///     - gptModelTemperature: (double, Default value: 0.4) temperature is a number between 0 and 2, when set higher the outputs
///             will be more random and possibly imprecise, closer to 0 the outputs will be more deterministic
///
/// Output Data:
///   - resolvedDistance: (Distance) The calculated distance between origin and destination after executing the methods fetchHumanDirections
///             or fetchHumanDirectionsFromLocation, if none of those methods are executed successfully the members text and value are null.
///   - resolvedTime: (Time): The calculated estimated time to go between origin and destination after executing the methods fetchHumanDirections
///             or fetchHumanDirectionsFromLocation, if none of those methods are executed successfully the members text and value are null.
///   - steps: (List<Step> type from package:google_directions_api) a list with each instruction step given by Direction API.
///   - directionsAPIRequestResultStatus: (String, Default value 'awaiting') the result from the request to Directions API.
///   - humanDirectionsResult: (String?) the string resulting from fetchHumanDirections or fetchHumanDirectionsFromLocation
///            - this is a JSON Map with the next format:
///               {
///                 "start_message": "any message to give context for the user before giving the instructions",
///                 "steps": "a list with each converted instruction as a map" [{
///                     "number": "the number of the instruction", //int
///                     "instruction": "the converted instruction",
///                   }],
///                 "end_message": "any context closing message for the user"
///              }
///   - nearbyPlacesFrom: (List<String>) the collection of nearby places relative to the start location of each step from direction API.
///   - nearbyPlacesTo: (List<String>) the collection of nearby places relative to the end location of each step from direction API.
///   - currentPosition: (GeoCoord type from package:google_directions_api): the user's current position, value null until the execution of
///             getCurrentLocation, fetchHumanDirectionsFromLocation or fetchHumanDirections.
///   - lastException: (String?) last exception given from any called method from this class.
///
/// Getters:
///   - directionsStepsList: (List<Step>?) Redundant returns [steps]
///   - directionsRequestResult: (String) Redundant returns [directionsAPIRequestResultStatus] that's the result from the request to Directions API.
///   - fetchResultFlag: (int)  returns [_resultFlag] that's the flag that indicates the result of the request to Directions API.
///   - fetchHumanDirectionsFlag: (int)  returns [_humanDirectionsFlag] that's the flag that indicates the result of the request to fetch human directions.
///   - updateFetchHumanDirections: (String?) Redundant returns [humanDirectionsResult] that's the result of the request to fetch human directions.
///   - humanDirectionsProcStatus: (String) Returns the current status of the human directions process.
///   - recommendationsProcStatus: (String) Returns the current status of the recommendations process.
class HumanDirections {
  /* flags */
  int _resultFlag = 1;
  int _humanDirectionsFlag = 1;
  /*Output Data */
  /// The calculated distance between origin and destination after executing the methods fetchHumanDirections
  /// or fetchHumanDirectionsFromLocation, if none of those methods are executed successfully the members text and value are null.
  Distance resolvedDistance = Distance(text: 'unknown', value: 0);

  /// The calculated estimated time to go between origin and destination after executing the methods fetchHumanDirections
  /// or fetchHumanDirectionsFromLocation, if none of those methods are executed successfully the members text and value are null.
  Time resolvedTime = Time(text: 'unknown', value: 0);

  ///A list with each instruction step given by Direction API.
  List<Step>? steps = [];

  /// The result Status from the request to Directions API.
  String directionsAPIRequestResultStatus = 'awaiting';

  /// The result of the request to fetch human directions.
  String? humanDirectionsResult = '';

  /// The collection of nearby places relative to the start location of each step from direction API.
  List<String> nearbyPlacesFrom = [];

  /// The collection of nearby places relative to the end location of each step from direction API.
  List<String> nearbyPlacesTo = [];

  /// The user's current position, value null until the execution of getCurrentLocation, fetchHumanDirectionsFromLocation or fetchHumanDirections.
  GeoCoord? currentPosition;

  /// The last exception given from any called method from this class.
  String? lastException;
  /* Parameters */
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  String openAIlanguage;
  final PlacesController _nearbyplacesController;
  String _prompt = '\n';
  String googlelanguage;
  UnitSystem unitSystem;
  TravelMode travelMode;
  double placesRadius;
  String gptModel;
  double gptModelTemperature;
  final HumanDirectionsLLMSystenMessages _systenMessages;
  /*Trackers*/
  String _humanDirectionsProcStatus = 'Not Started';
  String _recommendationsProcStatus = 'Not Started';

/*constructor*/
  HumanDirections(
      {required this.openAiApiKey,
      required this.googleDirectionsApiKey,
      this.googlelanguage = 'en',
      this.unitSystem = UnitSystem.metric,
      this.travelMode = TravelMode.walking,
      this.openAIlanguage = OpenAILanguage.en,
      this.placesRadius = 50.0,
      this.gptModel = OpenAiModelsNames.gpt4,
      this.gptModelTemperature = 0.4})
      : _nearbyplacesController =
            PlacesController(placesApiKey: googleDirectionsApiKey),
        _systenMessages =
            HumanDirectionsLLMSystenMessages(openAIlanguage: openAIlanguage);
  /* getters */
  List<Step>? get directionsStepsList => steps;
  String get directionsRequestResult => directionsAPIRequestResultStatus;
  int get fetchResultFlag => _resultFlag;
  int get fetchHumanDirectionsFlag => _humanDirectionsFlag;
  String? get updateFetchHumanDirections => humanDirectionsResult;
  String get humanDirectionsProcStatus => _humanDirectionsProcStatus;
  String get recommendationsProcStatus => _recommendationsProcStatus;
  /*Methods */

  ///Fetches human directions based on an specified origin and destination
  ///
  ///Parameters:
  ///   - origin: The origin to fetch directions to, as an Address or as geolocation(latitude, longitude).
  ///   - destination: The destination to fetch directions to, as an Address or as geolocation(latitude, longitude).
  ///
  /// Returns:
  ///   -0 if the directions were fetched successfully, 1 if an exception occurred.
  Future<int> fetchHumanDirections(String origin, String destination) async {
    _humanDirectionsProcStatus = 'Started';
    if ((origin.length < 20 || origin.isEmpty) ||
        (destination.length < 20 || destination.isEmpty)) {
      lastException = "The origin or destination is empty or is too short";
      _humanDirectionsProcStatus = 'Error';
      throw lastException!;
    }
    try {
      await _fetchDirections(origin, destination);
      return 0;
    } on Exception catch (e) {
      lastException = e.toString();
      return 1;
    }
  }

  /// Fetches human directions from the current location to the specified destination.
  ///
  /// If the current location is not available, it retrieves the current location first, however it is recommended to execute
  /// getCurrentLocation before this method.
  ///
  /// Parameters:
  ///   - destination: The destination to fetch directions to, as an Address or as geolocation(latitude, longitude).
  ///   - context: The build context used for fetching the current location,
  ///              its necessary as the Geolocation API needs to ask for permission to get the location
  ///
  /// Returns:
  ///   -0 if the directions were fetched successfully, 1 if an exception occurred.
  Future<int> fetchHumanDirectionsFromLocation(
      String destination, BuildContext context) async {
    _humanDirectionsProcStatus = 'Started';
    if (destination.length < 20 || destination.isEmpty) {
      lastException = "The destination is empty or is too short";
      _humanDirectionsProcStatus = 'Error';
      throw lastException!;
    }
    try {
      if (currentPosition == null) {
        _humanDirectionsProcStatus = 'Getting current location';
        await getCurrentLocation(context);
        _humanDirectionsProcStatus = 'Getting current location successful';
      }
      await _fetchDirections(
          '${currentPosition?.latitude},${currentPosition?.longitude}',
          destination);
      return 0;
    } on Exception catch (e) {
      _humanDirectionsProcStatus = 'Error fetching directions';
      lastException = e.toString();
      return 1;
    }
  }

  /// Gets the user's current location.
  ///
  /// Parameters:
  ///   - context: The build context used for fetching the current location,
  ///              its necessary as the Geolocation API needs to ask for permission to get the location
  ///
  /// Returns:
  ///   - 0 if the location
  Future<int> getCurrentLocation(BuildContext context) async {
    try {
      currentPosition = await GeoLocatorHandler().getLocation(context);
      return 0;
    } on Exception catch (e) {
      lastException = e.toString();
      return 1;
    }
  }

  /// Gets a set of recommendations of nearby places based on a user prompt such as "where can i get a drink?"
  ///
  /// Parameters:
  ///   - prompt: A string which is the question/prompt that's going to be asked to the llm in order to fetch recommendations.
  ///   - context: The build context used for fetching the current location,
  ///              its necessary as the Geolocation API needs to ask for permission to get the location
  Future<NearbyPlacesRecomendationsObject> getNearbyRecommendations(
      String prompt, BuildContext context) async {
    _recommendationsProcStatus = 'Started';
    await getCurrentLocation(context);
    return await _gptPromptNearbyPlaces(prompt, currentPosition!)
        .timeout(const Duration(minutes: 2));
  }

  /// Primary method to fetxh directions, internal use.
  Future<int> _fetchDirections(String origin, String destination) async {
    DirectionsService directionsService = DirectionsService();
    DirectionsService.init(googleDirectionsApiKey);
    _humanDirectionsProcStatus = 'Fetching Directions from Google API';
    final request = DirectionsRequest(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
        unitSystem: unitSystem,
        language: googlelanguage);

    // Create a Completer
    var completer = Completer<int>();

    directionsService.route(request,
        (DirectionsResult response, DirectionsStatus? status) async {
      if (status == DirectionsStatus.ok) {
        resolvedDistance.text =
            response.routes![0].legs![0].distance?.text ?? 'unknown';
        resolvedDistance.value = num.tryParse(resolvedDistance.text) ?? 0;
        resolvedTime.text =
            response.routes![0].legs![0].duration?.text ?? 'unknown';
        resolvedTime.value = num.tryParse(resolvedTime.text) ?? 0;
        steps = response.routes![0].legs![0].steps;
        await _buildAndPost();
        directionsAPIRequestResultStatus = 'OK';
        // Use completer to complete the Future
        completer.complete(0); // Assuming 0 indicates success
      } else {
        _resultFlag = 2;
        directionsAPIRequestResultStatus =
            'Error: $status : ${response.errorMessage}';
        // Use completer to complete the Future with an error state
        completer.complete(_resultFlag);
      }
    });

    // Return the Future controlled by the Completer
    return completer.future;
  }

  /// The method used to give the directions to chatgpt and fetch human directions, internal use
  Future<void> _gptPrompt(String prompt) async {
    _humanDirectionsProcStatus = 'Fetching Human Directions from LLM';
    OpenAI.apiKey = openAiApiKey;
    final systemMessage = _systenMessages.humanDirectionsSysMsg;

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

      _humanDirectionsFlag = 0;
      _humanDirectionsProcStatus =
          'Fetching Human Directions from LLM successful';
    } catch (e) {
      _humanDirectionsProcStatus = 'Error fetching Human Directions from LLM';
      humanDirectionsResult = 'Exception: $e';
      _humanDirectionsFlag = 2;
    }
  }

  /// Full method to fetch recommendations for nearby places, internal use.
  Future<NearbyPlacesRecomendationsObject> _gptPromptNearbyPlaces(
      String prompt, GeoCoord location) async {
    try {
      OpenAI.apiKey = openAiApiKey;
      final systemMessage = _systenMessages.recommendationsSysMsg;

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
      _recommendationsProcStatus = 'Sending prompt to LLM';
      final chat = await OpenAI.instance.chat.create(
        model: gptModel,
        messages: requestMessages,
        temperature: gptModelTemperature,
        tools: [tools],
      ).timeout(const Duration(seconds: 40));
      final message = chat.choices.first.message;
      if (message.haveToolCalls) {
        _recommendationsProcStatus =
            'LLM response received, processing tool request';
        final call = message.toolCalls!.first;
        if (call.function.name ==
            HumanDirectionsLLMTools.recommendationTool.function.name) {
          final decodedArgs = jsonDecode(call.function.arguments);

          final latitude = decodedArgs[RecommendationToolArgs.latitude.name];
          final longitude = decodedArgs[RecommendationToolArgs.longitude.name];
          final categories = List<String>.from(
              decodedArgs[RecommendationToolArgs.categories.name]);
          final radius = decodedArgs[RecommendationToolArgs.radius.name];
          _recommendationsProcStatus = 'Fetching nearby places';
          final result = await _nearbyplacesController
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
      _recommendationsProcStatus = 'Fetching recommendations';
      final List<OpenAIStreamChatCompletionModel> completions =
          await secondChat.toList().timeout(const Duration(minutes: 1));

      String secondResponseMessage = '';

      for (var streamChatCompletion in completions) {
        final content = streamChatCompletion.choices.first.delta.content;
        secondResponseMessage += (content?[0]?.text ?? '');
      }
      if (secondResponseMessage.length > 10) {
        _recommendationsProcStatus = 'Parsing LLM response';
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
          _recommendationsProcStatus =
              'Fetching photos ids for each recommendation';
          photosId.add(await _nearbyplacesController
              .fetchPlacePhotosData(element.id)
              .timeout(const Duration(seconds: 40)));
        }
        int i = 0;
        for (var element in photosId) {
          _recommendationsProcStatus =
              'Fetching photos uris for each recommendation';
          photosRep[i]['uri_collection'] = await _nearbyplacesController
              .fetchPhotosUris(element,
                  width: 400, height: 400, maxOperations: 1)
              .timeout(const Duration(seconds: 40));
          i++;
        }
        output.recomendationPhotos =
            PhotoCollection(placePhotoUriCollection: photosRep);
        _recommendationsProcStatus = 'Finished successfully';
        return output;
      } else {
        _recommendationsProcStatus = 'Error';
        return NearbyPlacesRecomendationsObject.fromError(
            Exception('LLM response is empty'));
      }
    } catch (e) {
      _recommendationsProcStatus = 'Error';
      return NearbyPlacesRecomendationsObject.fromError(e);
    }
  }

  /// Builds a string containing all the nearrby places and puts them into the corresponding list, internal use.
  Future<void> _getAllNearbyPlaces() async {
    _humanDirectionsProcStatus = 'Fetching Nearby Places for each step';
    for (int i = 0; i < (steps?.length ?? 0); i++) {
      nearbyPlacesFrom.add(
          await _nearbyplacesController.fetchAndSummarizeNearbyPlaces(
              steps?[i].startLocation, placesRadius));
    }
    for (int i = 0; i < (steps?.length ?? 0); i++) {
      nearbyPlacesTo.add(await _nearbyplacesController
          .fetchAndSummarizeNearbyPlaces(steps?[i].endLocation, placesRadius));
    }
    _humanDirectionsProcStatus =
        'Fetching Nearby Places for ech step successful';
  }

  /// Builds one string with all the info needed by the AI and then makes the post request, internal use.
  Future<void> _buildAndPost() async {
    _humanDirectionsProcStatus =
        'Fetching Directions from Google API successful';
    await _getAllNearbyPlaces();
    for (int i = 0; i < (steps?.length ?? 0); i++) {
      String currentDir =
          '${i + 1} - From: ${steps?[i].startLocation.toString()} (Nearby Places: ${nearbyPlacesFrom[i]} ),to: ${steps?[i].endLocation.toString()} (Nearby Places: ${nearbyPlacesTo[i]}), Instructions: ${steps?[i].instructions},Distance:${steps?[i].distance?.text}  ,Time:${steps?[i].duration?.text}  , Maneuver: ${steps?[i].maneuver} \n';
      _prompt = _prompt + currentDir;
    }
    await _gptPrompt(_prompt);
    _resultFlag = 0;
  }
}
