import 'package:dart_openai/dart_openai.dart';

import 'package:human_directios/componets/llm/tools/arguments.dart';
import 'package:human_directios/componets/llm/tools/tool_builder.dart';
import 'package:human_directios/componets/places/places_types.dart';

class HumanDirectionsLLMTools {
  static OpenAIToolModel recommendationTool =
      ToolBuilder(components: _recommendationToolComponents).buildTool();
}

ToolHeader _recommendationToolHeaders = ToolHeader(
    type: 'function',
    name: 'fetchNearbyPlaces',
    description: 'obtain nearby places, all parameters are required');

class RecommendationToolArgs {
  static ToolArg latitude = ToolArg(
      name: 'latitude',
      description: 'the user location latitude value',
      type: Argtype.number,
      isRequired: true);
  static ToolArg longitude = ToolArg(
      name: 'longitude',
      description: 'the user location longitude value',
      type: Argtype.number,
      isRequired: true);
  static ToolArg category = ToolArg(
      name: 'category',
      description: 'Place category, e.g. bar, library',
      type: Argtype.string,
      isRequired: true,
      enumValues: placesTypesList);
  static ToolArg radius = ToolArg(
      name: 'radius',
      description:
          'radius in meters around the user location where the places are going to be looked up to',
      type: Argtype.number,
      isRequired: true);
}

List<ToolArg> _recommendationToolArgsList = [
  RecommendationToolArgs.latitude,
  RecommendationToolArgs.longitude,
  RecommendationToolArgs.category,
  RecommendationToolArgs.radius
];

ToolComponents _recommendationToolComponents = ToolComponents(
    header: _recommendationToolHeaders, args: _recommendationToolArgsList);
