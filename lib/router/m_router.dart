import 'package:analyzer/dart/constant/value.dart';

class MRouter {
  final Map<String, dynamic> params;
  final List<String> aliasNames;
  final String url;
  final String desc;

  const MRouter({
    this.url,
    this.desc,
    this.params,
    this.aliasNames,
  });
}

class MXCWriterRouter {
  final List<String> importList;

  const MXCWriterRouter({this.importList = const []});
}

class FieldInfo {
  final String type;
  final dynamic target;

  const FieldInfo(this.type, this.target);

  @override
  String toString() {
    return "FieldInfo====>type = $type,target = $target";
  }
}



class MRouterInfo {
  final Map<DartObject, DartObject> params;
  final List<DartObject> aliasNames;
  final String url;
  final String desc;
  final String path;

  const MRouterInfo({
    this.url,
    this.desc,
    this.params,
    this.aliasNames,
    this.path,
  });
}
