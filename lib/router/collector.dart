import 'dart:collection';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:gif_image/router/m_router.dart';
import 'package:gif_image/router/utils/utils.dart';
import 'package:gif_image/router/writer/tpl.dart';
import 'package:gif_image/router/writer/writer.dart';

const _packWhiteList = ['core'];

class Collector {
  Map<String, MRouterInfo> _params = {};
  Map<String, String> _clsCaches = {};

  DartWriter dWriter = DartWriter();

  void collect(String url, MRouterInfo router, String clsName) {
    _params[url] = router;
    _clsCaches[url] = clsName;
  }

  String write() {
    return _parse();
  }

  String _parse() {
    dWriter.appendImport("import 'package:flutter/material.dart';");
    dWriter.appendImport(
        "import 'package:gif_image/router/router_provider.dart';");
    ExtensionWriter extensionWriter =
        dWriter.createNewExtension('MXCRouterBuildContext', 'BuildContext');
    _writeCommonExt(extensionWriter);

    var onGenerateRoute = dWriter.createMethod(
        returnType: 'Route<dynamic>',
        name: 'mxcOnGenerateRoute',
        params: [FieldWriter(type: 'RouteSettings', name: 'settings')],
        isParamNamed: false);

    List<SwitchTplModel> routerArgs = [];

    _params.forEach((key, value) {
      Map<DartObject, DartObject> params = value.params;
      Map<FieldInfo, FieldInfo> _paramsInfo = {};
      if (params != null) {
        params.forEach((key, value) {
          FieldInfo keyInfo = FieldInfo('String', key.toStringValue());
          _paramsInfo[keyInfo] = _formatDartObject(value);
        });
      }
      List<FieldWriter> _fieldWriter = [];
      _paramsInfo.forEach((key, value) {
        _fieldWriter.add(FieldWriter(
            type: value.type,
            name: '\$${key.target}',
            isFinal: true,
            isConstructorParamsAndHasThisField: true));
      });

      String _url = Utils.getNameByUrl(value.url);

      String modelName = '\$${_url}Model';
      ClassWriter modelCls = dWriter.createNewClass(modelName);

      _fieldWriter.forEach((element) {
        modelCls.addField(element);
      });

      modelCls.createConstructor(fields: _fieldWriter, isConst: true);

      String _switchTplContent = '''
        return MXCRouter.instance.provider.buildCustomRoute("${value.url}",  settings.arguments,(context){
      return ${_clsCaches[value.url] == null ? "MXCRouter.instance.provider.buildNotFoundWidget(settings)" : "${_clsCaches[value.url]}()"};
    });
      ''';

      List<String> _aliasName = value.aliasNames.map((e) {
        return e.toStringValue();
      }).toList();

      routerArgs.add(SwitchTplModel('${value.url}', '$_switchTplContent',
          switchCases: _aliasName));

      List<FieldWriter> _methodField = _fieldWriter.map((e) {
        return FieldWriter(
            type: e.type,
            name: e.name,
            isFinal: e.isFinal,
            isConstructorParamsAndHasThisField:
                e.isConstructorParamsAndHasThisField,
            value: e.name);
      }).toList();
      MethodWriter pushTo = extensionWriter.createMethod(
          returnType: 'Future<T>',
          name: 'pushNameTo$_url<T>',
          params: _fieldWriter,
          isParamNamed: true);
      pushTo.appendMethodContent(
          " return this.routerProvider.pushName<T>(this, '${value.url}',arguments: ${modelCls.toInitializedString(fields: _methodField, isParamNamed: true)});");

      var argumentsCurrentAsync = extensionWriter.createMethod(
        returnType: 'Future<$modelName>',
        name: 'argumentsAsync$_url',
        params: [],
        isAsync: true,
      );
      argumentsCurrentAsync.appendMethodContent('''
       return argumentsAsync<$modelName>();
      ''');

      var argumentsCurrent = extensionWriter.createMethod(
        returnType: modelName,
        name: 'arguments$_url',
        params: [],
        isAsync: false,
      );
      argumentsCurrent.appendMethodContent('''
       return arguments<$modelName>();
      ''');
    });

    onGenerateRoute.appendSwitch('settings.name', routerArgs);

    onGenerateRoute.appendMethodContent('''
    return MXCRouter.instance.provider
          .buildCustomRoute(settings.name, settings.arguments, (context) {
        return MXCRouter.instance.provider.buildNotFoundWidget(settings);
      });
    ''');

    return dWriter.toWriterString();
  }

  void _writeCommonExt(ExtensionWriter extensionWriter) {
    MethodWriter createMethod2 = extensionWriter.createMethod(
        returnType: 'Future<T>',
        name: 'argumentsAsync<T>',
        params: [],
        isAsync: true,
        isParamNamed: true);

    createMethod2.appendMethodContent('''
     return this.routerProvider.argumentsAsync(this);
    ''');

    MethodWriter createMethod3 = extensionWriter.createMethod(
        returnType: 'T',
        name: 'arguments<T>',
        params: [],
        isAsync: false,
        isParamNamed: true);

    createMethod3.appendMethodContent('''
      return this.routerProvider.arguments(this);
    ''');
  }

  FieldInfo _formatDartObject(DartObject dartObject) {
    if (dartObject == null || dartObject.isNull) return null;
    FieldInfo info;
    info = _formatParamType(dartObject);
    return info;
  }

  bool isNotInWhiteList(String path) {
    return _packWhiteList.where((element) {
      return path.startsWith(element);
    }).isEmpty;
  }

  FieldInfo _formatParamType(DartObject dartObject) {
    FieldInfo info;
    ParameterizedType type = dartObject.type;
    //判断其为type
    if (dartObject.toTypeValue() != null) {
      DartType type = dartObject.toTypeValue();
      var path = type?.element?.source?.uri?.path;
      if (path != null && isNotInWhiteList(path)) {
        dWriter.appendImport('package:$path');
      }

      info = FieldInfo(type.getDisplayString(withNullability: false),
          type.element.runtimeType);
    } else if (type.isDartCoreString) {
      info = FieldInfo('String', dartObject?.toStringValue() ?? "");
    } else if (type.isDartCoreBool) {
      info = FieldInfo('bool', dartObject?.toBoolValue() ?? false);
    } else if (type.isDartCoreDouble) {
      info = FieldInfo('double', dartObject?.toDoubleValue() ?? 0.0);
    } else if (type.isDartCoreInt) {
      info = FieldInfo('int', dartObject?.toIntValue() ?? 0);
    } else if (type.isDartCoreList) {
      List<DartObject> list = dartObject?.toListValue();
      if (list == null || list.isEmpty) {
        info = FieldInfo("List<dynamic>", []);
      } else {
        bool _sameObj = true;
        List<dynamic> _tmp = [];
        FieldInfo _firstInfo = _formatDartObject(list[0]);
        _tmp.add(_firstInfo.target);
        for (int i = 1; i < list.length; i++) {
          DartObject obj = list[i];
          FieldInfo _info = _formatDartObject(obj);
          if (_firstInfo.type != _info.type) {
            _sameObj = false;
          }
          _tmp.add(_info.target);
        }
        if (_sameObj) {
          info = FieldInfo("List<${_firstInfo.type}>", _tmp);
        } else {
          info = FieldInfo("List<dynamic>", _tmp);
        }
      }
    } else if (type.isDartCoreMap) {
      Map<DartObject, DartObject> map = dartObject?.toMapValue();
      if (map == null || map.isEmpty) {
        info = FieldInfo("Map<dynamic,dynamic>", {});
      } else {
        bool isSameKey = true, isSameValue = true;
        FieldInfo _lastKeyInfo, _lastValueInfo;
        Map<dynamic, dynamic> _tmp = {};
        map.forEach((key, value) {
          FieldInfo keyInfo = _formatDartObject(key);
          FieldInfo valueInfo = _formatDartObject(value);
          _lastKeyInfo ??= keyInfo;
          _lastValueInfo ??= valueInfo;
          if (_lastKeyInfo.type != keyInfo.type) {
            isSameKey = false;
          }
          if (_lastValueInfo.type != valueInfo.type) {
            isSameValue = false;
          }
          _tmp[keyInfo.target] = [valueInfo.target];
        });
        if (isSameKey && isSameValue) {
          info = FieldInfo(
              "Map<${_lastKeyInfo.type},${_lastValueInfo.type}>", _tmp);
        } else if (isSameKey && !isSameValue) {
          info = FieldInfo("Map<${_lastKeyInfo.type},dynamic>", _tmp);
        } else if (!isSameKey && isSameValue) {
          info = FieldInfo("Map<dynamic,${_lastValueInfo.type}>", _tmp);
        } else {
          info = FieldInfo("Map<dynamic,dynamic>", _tmp);
        }
      }
    } else if (type.isDartCoreSet) {
      Set<DartObject> set = dartObject?.toSetValue();
      if (set == null || set.isEmpty) {
        info = FieldInfo("Set<dynamic>", LinkedHashSet());
      } else {
        bool isSameE = true;
        Set<dynamic> _tmp = LinkedHashSet();
        FieldInfo _lastInfo;
        set.forEach((element) {
          FieldInfo eInfo = _formatDartObject(element);
          _lastInfo ??= eInfo;
          if (_lastInfo.type != eInfo.type) {
            isSameE = false;
          }
          _tmp.add(eInfo.target);
        });
        if (isSameE) {
          info = FieldInfo("Set<${_lastInfo.type}>", _tmp);
        } else {
          info = FieldInfo("Set<dynamic>", _tmp);
        }
      }
    } else if (type.isDartCoreFunction) {
      info = FieldInfo("dynamic", dartObject?.toFunctionValue()?.name ?? '');
    } else {
      info = FieldInfo("dynamic", type.element.runtimeType);
    }
    return info;
  }
}
