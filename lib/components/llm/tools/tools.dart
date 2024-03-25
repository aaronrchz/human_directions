import 'package:dart_openai/dart_openai.dart';

import 'arguments.dart';
import 'tool_builder.dart';
import '../../places/places_types.dart';

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
  static ToolArg categories = ToolArg(
      name: 'category',
      description: 'List of place category, e.g. bar, library',
      type: Argtype.array,
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
  RecommendationToolArgs.categories,
  RecommendationToolArgs.radius
];

ToolComponents _recommendationToolComponents = ToolComponents(
    header: _recommendationToolHeaders, args: _recommendationToolArgsList);
