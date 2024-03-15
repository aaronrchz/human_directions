class ToolHeader {
  final String type;
  final String name;
  final String description;
  ToolHeader(
      {required this.type, required this.name, required this.description});
}

enum Argtype{
  string,
  integer,
  //array, //not implemented for the moment
  //object,//not implemented for the moment
  //primitive,//not implemented for the moment
  boolean,
  number,
}

enum ToolTypeEnum{
  funciton,
}

Map<ToolTypeEnum, String>toolType = {
  ToolTypeEnum.funciton : 'funcion'
};

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

class ToolComponents {
  final ToolHeader header;
  final List<ToolArg> args;
  ToolComponents({required this.header, required this.args});
}
