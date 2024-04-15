import 'package:dart_openai/dart_openai.dart';
import '../places/places_types.dart';

/// This class holds the system messages used for the human directions and recommendations for the LLM.
class HumanDirectionsLLMSystenMessages {
  final String openAIlanguage;
  final String travelMode;
  final OpenAIChatCompletionChoiceMessageModel humanDirectionsSysMsg;
  final OpenAIChatCompletionChoiceMessageModel recommendationsSysMsg;
  HumanDirectionsLLMSystenMessages(
      {required this.openAIlanguage, required this.travelMode})
      : humanDirectionsSysMsg = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          Convert this instruction set to a more human-friendly format. 
          Specify when mentioning a street, avenue, etc.
          Be extra friendly.
          Always use the given nearby places to better guide the user.
          If there is not an instruction set, just say 'Oops! It seems there are no valid instructions.'
          Use the next format to give your response:
          {
            "start_message": "any message to give context for the user before giving the instructions",
            "steps": "a list with each converted instruction as a map"[{
              "number": "the number of the instruction, must be a number",
              "instruction": "the converted instruction",
            }],
            "end_message": "any context closing message for the user"
          }
          Remember that the user will be using $travelMode to get to the destination.
          Answer the user in $openAIlanguage. 
          """),
          ],
        ),
        recommendationsSysMsg = OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              """
          The user will give their location and ask for recommendations about where to go
          in the following text, please extract and deliver a list of the following categories:
          categories: $placesTypesList
          however, if the place is not open at the moment, do not recommend it or mark it as closed.
          Avoid using links.
          The recommendations must be ranked by rating and how well they fit into the user prompt
          The output must be a map with the following format and no field must be null, if any field is missing put the string "missing" instead:
          {
            "start_message": "any message to give context to the user",
            "recommendations" : [{
              "id": "place id given by the api",
              "description": "String, short description inferred based on the data provided.",
            }],
            "closing_message": "any message to give context to the user" 
          }
          No part of the response must be outside of the map
          Remember that the user will be using $travelMode to get to the destination.
          Answer the user in: $openAIlanguage.
          """,
            ),
          ],
          role: OpenAIChatMessageRole.assistant,
        );
}
