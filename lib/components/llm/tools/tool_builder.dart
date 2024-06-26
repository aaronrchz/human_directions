import 'package:dart_openai/dart_openai.dart';
import '../tools/arguments.dart';

/// This class holds the method to build a usable tool for the LLM returning an object compatible with the package dart_openai.
class ToolBuilder {
  final ToolComponents components;

  ToolBuilder({required this.components});

  OpenAIToolModel buildTool() {
    final List<OpenAIFunctionProperty> functionParameters = [];
    for (var arg in components.args) {
      switch (arg.type) {
        case Argtype.string:
          if (arg.enumValues != null) {
            functionParameters.add(OpenAIFunctionProperty.string(
                name: arg.name,
                description: arg.description,
                isRequired: arg.isRequired,
                enumValues: arg.enumValues));
          } else {
            functionParameters.add(OpenAIFunctionProperty.string(
                name: arg.name,
                description: arg.description,
                isRequired: arg.isRequired));
          }
          break;
        case Argtype.number:
          functionParameters.add(OpenAIFunctionProperty.number(
              name: arg.name,
              description: arg.description,
              isRequired: arg.isRequired));
          break;
        case Argtype.integer:
          functionParameters.add(OpenAIFunctionProperty.integer(
              name: arg.name,
              description: arg.description,
              isRequired: arg.isRequired));
          break;
        case Argtype.boolean:
          functionParameters.add(OpenAIFunctionProperty.boolean(
              name: arg.name,
              description: arg.description,
              isRequired: arg.isRequired));
          break;
        case Argtype.array:
          //for the moment only supports items of the type string
          functionParameters.add(
            OpenAIFunctionProperty.array(
              name: arg.name,
              description: arg.description,
              isRequired: arg.isRequired,
              items: OpenAIFunctionProperty.string(
                  name: 'item', description: 'Array item', isRequired: true),
            ),
          );
          break;
        /*case Argtype.object:
        /* uninplemented for the moment*/
        case Argtype.primitive:
          /* uninplemented for the moment*/
          break;*/
        default:
          break;
      }
    }

    return OpenAIToolModel(
      type: components.header.type,
      function: OpenAIFunctionModel.withParameters(
          name: components.header.name,
          description: components.header.description,
          parameters: functionParameters),
    );
  }
}
