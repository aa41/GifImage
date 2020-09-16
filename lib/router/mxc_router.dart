import 'dart:collection';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:gif_image/router/collector.dart';
import 'package:gif_image/router/m_router.dart';
import 'package:gif_image/router/utils/utils.dart';
import 'package:gif_image/router/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class MxcRouterGen extends GeneratorForAnnotation<MRouter> {
  static Collector collector = new Collector();

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation,
      BuildStep buildStep) {
    if (element is! ClassElement) throw "must annotated on class";
    if (element is ClassElement) {
      bool isWidget = false;
      element.allSupertypes.forEach((element) {
        if (element.toString() == 'StatelessWidget' ||
            element.toString() == 'StatefulWidget' ||
            element.toString() == 'Widget') {
          isWidget = true;
        }
      });
      if (!isWidget) throw "must annotated on Widget";
    }

    if (buildStep.inputId.path.contains('lib/')) {
      collector.dWriter.appendImport(
          "package:${buildStep.inputId.package}/${buildStep.inputId.path
              .replaceFirst('lib/', '')}");
    } else {
      collector.dWriter.appendImport("${buildStep.inputId.path};");
    }


    var aliasNamesField = annotation.peek("aliasNames");
    var urlField = annotation.peek("url");
    var descField = annotation.peek("desc");
    var paramsField = annotation.peek("params");

    if (urlField == null || urlField?.stringValue == null)
      throw 'must rewrite url';
    MRouterInfo _router = MRouterInfo(
        url: urlField.stringValue,
        desc: descField?.stringValue ?? '',
        aliasNames: aliasNamesField.listValue ?? [],
        params: paramsField?.mapValue ?? {});

    collector.collect(urlField.stringValue, _router, element.name);

    return null;
  }
}

class MXCWriteRouterGen extends GeneratorForAnnotation<MXCWriterRouter> {
  Collector getCollector() {
    return MxcRouterGen.collector;
  }

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation,
      BuildStep buildStep) {
    if (element is! ClassElement) throw "must annotated on class";



    return getCollector().write();
  }
}
