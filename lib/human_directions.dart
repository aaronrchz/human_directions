import 'package:google_directions_api/google_directions_api.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:human_directios/componets/places.dart';
import 'package:human_directios/componets/supported_lenguages.dart';

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
