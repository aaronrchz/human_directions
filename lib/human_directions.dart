import 'package:google_directions_api/google_directions_api.dart';
import 'package:dart_openai/dart_openai.dart';

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
  /* Parameters */
  final String openAiApiKey;
  final String googleDirectionsApiKey;
  String prompt;
  String lenguage;
  UnitSystem unitSystem;
  TravelMode travelMode;

  HumanDirections({
    required this.openAiApiKey,
    required this.googleDirectionsApiKey,
    this.prompt =
        'Convierte este set de instreucciones en un set mas amigable para humanos, como si hablaras con una persona que no conoce la ciudad, especifica cuando se hace referencia a una calle, avenida etc.: \n',
    this.lenguage = 'es-419',
    this.unitSystem = UnitSystem.metric,
    this.travelMode = TravelMode.walking,
  });
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

  int _fetchDirections(String origin, String destination) {
    DirectionsService directionsService = DirectionsService();
    DirectionsService.init(googleDirectionsApiKey);

    final request = DirectionsRequest(
        origin: origin,
        destination: destination,
        travelMode: travelMode,
        unitSystem: unitSystem,
        language: lenguage);

    directionsService.route(request,
        (DirectionsResult response, DirectionsStatus? status) {
      if (status == DirectionsStatus.ok) {
        resolvedDistance.text = response.routes![0].legs![0].distance?.text;
        resolvedTime.text = response.routes![0].legs![0].duration?.text;
        steps = response.routes![0].legs![0].steps;
        for (int i = 0; i < (steps?.length ?? 0); i++) {
          String currentDir =
              '${i + 1} - From: ${steps?[i].startLocation.toString()} to: ${steps?[i].endLocation.toString()}, Instructions: ${steps?[i].instructions},Distance:${steps?[i].distance?.text}  ,Time:${steps?[i].duration?.text}  , Maneuver: ${steps?[i].maneuver}\n';
          prompt = prompt + currentDir;
        }
        _gptPrompt(prompt);
        resultFlag = 0;
        requestResult = 'OK';
      } else {
        resultFlag = -1;
        requestResult = 'Error: $status';
      }
    });
    return resultFlag;
  }

  Future<void> _gptPrompt(String prompt) async {
    OpenAI.apiKey = openAiApiKey;
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "Use casual lenguage",
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

    final chat = await OpenAI.instance.chat.create(
      model: "gpt-4",
      messages: requestMessages,
    );
    humanDirectionsResult = chat.choices[0].message.content?[0].text;

    humanDirectionsFlag = 0;
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
