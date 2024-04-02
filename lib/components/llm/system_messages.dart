import 'package:dart_openai/dart_openai.dart';
import '../places/places_types.dart';

class HumanDirectionsLLMSystenMessages {
  final String openAIlenguage;
  final OpenAIChatCompletionChoiceMessageModel humanDirectionsSysMsg;
  final OpenAIChatCompletionChoiceMessageModel recommendationsSysMsg;
  HumanDirectionsLLMSystenMessages({required this.openAIlenguage})
      : humanDirectionsSysMsg = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          Convert this instruction set to a more human-friendly format. 
          Specify when mentioning a street, avenue, etc.
          Be extra friendly.
          Always use the given nearby places to better guide the user.
          If there is not an instruction set, just say 'Ooops! it seems there are not valid instructions.'
          Use the next format to give your response:
          {
            "start_message": "any message to give context for the user before giving the instructions",
            "steps":"a list with each converted instruction as a map"[{
              "number": "the number odf the instruction, must be a number",
              "instruction": "the converted instruction",
            }],
            "end_message": "any context closing message for the user"
          }
          Answer the user in $openAIlenguage. 
          """),
          ],
        ),
        recommendationsSysMsg = OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              """
          The user will give thier location and ask for recommendations about were to go
          in the following text, please extract and deliver a list of the following categories:
          getegories: $placesTypesList
          however if the place is not open at the moment do not recommend it or mark it as closed.
          Avoid using Links.
          The output mus be a map with the following format and none filed must be null, if any field is missing put the string "missing" instead:
          {
            "start_message": "any messsage to give contex to the user",
            "recommendations" : [{
              "id": "place id given by the api"
              "name": "String, Place name",
              "address": "String, Place Address",
              "rating": 'String, Place rating',
              "description": "String, a shrot polace description based on place type, and name",
              "opening_hours": "String, Place Opening hours" ,
              "phone_numer": "String, place phone number"
            }],
            "closing_message": "any messsage to give contex to the user" 
          }
          None part of the response must be outside of the map
          answer the user in: $openAIlenguage.
          """,
            ),
          ],
          role: OpenAIChatMessageRole.assistant,
        );
}
