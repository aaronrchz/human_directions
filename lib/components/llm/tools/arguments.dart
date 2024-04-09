/// This file Hold all the clases to build a tool for the LLM.

/// Tool header class., used to hold the descriptions for the AI Tools.
class ToolHeader {
  final String type;
  final String name;
  final String description;
  ToolHeader(
      {required this.type, required this.name, required this.description});
}

/// all the posible types for the arguments of the tools.
enum Argtype {
  string,
  integer,
  array,
  //object,//not implemented for the moment
  //primitive,//not implemented for the moment
  boolean,
  number,
}

///All the posibles types of tools
enum ToolTypeEnum {
  funciton,
}

//Map<ToolTypeEnum, String> toolType = {ToolTypeEnum.funciton: 'funcion'};

/// All the data to describe the arguments of the tools.
class ToolArg {
  final String name;
  final String description;
  final Argtype type;
  final bool isRequired;
  List<String>? enumValues;
  ToolArg({
    required this.name,
    required this.description,
    required this.type,
    required this.isRequired,
    this.enumValues,
  });
}

///
class ToolComponents {
  final ToolHeader header;
  final List<ToolArg> args;
  ToolComponents({required this.header, required this.args});
}
