import 'dart:collection';
import 'package:gif_image/router/writer/tpl.dart';

class DartWriter {
  Set<String> _import = LinkedHashSet();

  Map<String, IWriter> _classCaches = {};

  Set<ExtensionWriter> _extensionCaches = LinkedHashSet();

  Set<MethodWriter> _methodCaches = LinkedHashSet();

  Set<FieldWriter> _fieldCaches = LinkedHashSet();

  ClassWriter createNewClass(String className) {
    ClassWriter _clsWriter = new ClassWriter(className);
    _classCaches[className] = _clsWriter;
    return _clsWriter;
  }

  MethodWriter createMethod({
    String returnType,
    bool isStatic = false,
    String name,
    List<FieldWriter> params,
    bool isOverride = false,
    bool isParamNamed = true,
    bool isAsync = false,
  }) {
    MethodWriter writer = new MethodWriter(
        returnType: returnType,
        isStatic: isStatic,
        name: name,
        params: params,
        isOverride: isOverride,
        isAsync: isAsync,
        isParamNamed: isParamNamed);
    _methodCaches.add(writer);
    return writer;
  }

  ExtensionWriter createNewExtension(
      String extensionName, String extensionType) {
    var writer = ExtensionWriter(
        extensionName: extensionName, extensionType: extensionType);
    _extensionCaches.add(writer);
    return writer;
  }

  void addField(FieldWriter fieldWriter) {
    _fieldCaches.add(fieldWriter);
  }

  void appendImport(String import) {
    if (!import.trimLeft().startsWith('import')) {
      import = "import '$import'";
    }
    if (!import.trimRight().endsWith(';')) {
      import += ';';
    }
    import += '\r\n';

    _import.add(import);
  }

  String toWriterString() {
    StringBuffer _buffer = new StringBuffer('');

    _import.forEach((element) {
      _buffer.write(element);
    });

    _fieldCaches.forEach((element) {
      _buffer.write(element.toWriterString());
    });

    _methodCaches.forEach((element) {
      _buffer.write(element.toWriterString());
    });

    _classCaches.forEach((key, value) {
      _buffer.write(value.toWriterString());
    });
    _extensionCaches.forEach((element) {
      _buffer.write(element.toWriterString());
    });

    return _buffer.toString();
  }
}

class ExtensionWriter extends IWriter {
  final String extensionName;
  final String extensionType;

  Set<MethodWriter> _methodCaches = LinkedHashSet();

  ExtensionWriter({this.extensionName, this.extensionType});

  @override
  void end() {}

  @override
  void start() {}

  MethodWriter createMethod({
    String returnType,
    String name,
    List<FieldWriter> params,
    bool isParamNamed = true,
    bool isAsync = false,
  }) {
    MethodWriter writer = new MethodWriter(
        returnType: returnType,
        isStatic: false,
        name: name,
        params: params,
        isOverride: false,
        isAsync: isAsync,
        isParamNamed: isParamNamed);
    _methodCaches.add(writer);
    return writer;
  }

  @override
  String toWriterString() {
    StringBuffer _buffer = new StringBuffer('');
    _methodCaches.forEach((element) {
      _buffer.write(element.toWriterString());
    });
    return createExtension(
        extensionName: extensionName,
        extensionType: extensionType,
        content: _buffer.toString());
  }
}

extension A on String {}

class ClassWriter extends IWriter {
  final String className;

  Set<FieldWriter> _fieldCaches = LinkedHashSet();
  Set<MethodWriter> _methodCaches = LinkedHashSet();
  Set<String> _constructorCaches = LinkedHashSet();

  ClassWriter(this.className);

  void addField(FieldWriter fieldWriter) {
    _fieldCaches.add(fieldWriter);
  }

  //todo 参数可选 super等
  void createConstructor({List<FieldWriter> fields, bool isConst}) {
    StringBuffer _tmp = new StringBuffer('');

    fields.forEach((element) {
      _tmp.write('${element.toConstructorString()}');
    });

    String tpl = createConstructorTpl(
        className: className,
        isParamsNamed: true,
        params: _tmp.toString(),
        isConst: isConst);
    _constructorCaches.add(tpl);
  }

  MethodWriter createMethod({
    String returnType,
    bool isStatic = false,
    String name,
    List<FieldWriter> params,
    bool isOverride = false,
    bool isParamNamed = true,
    bool isAsync = false,
  }) {
    MethodWriter writer = new MethodWriter(
        returnType: returnType,
        isStatic: isStatic,
        name: name,
        params: params,
        isOverride: isOverride,
        isAsync: isAsync,
        isParamNamed: isParamNamed);
    _methodCaches.add(writer);
    return writer;
  }

  String toInitializedString(
      {List<FieldWriter> fields = const [], bool isParamNamed = true}) {
    StringBuffer _buffer = new StringBuffer('');
    fields.forEach((element) {
      if (isParamNamed) {
        _buffer.write('${element.name} : ${element.value} ,');
      } else {
        _buffer.write('${element.value} ,');
      }
    });
    var _tpl = _buffer.toString();
    if (_tpl.contains(',')) {
      _tpl = _tpl.substring(0, _tpl.length - 1);
    }
    return createInitializeTpl(className: className, params: _tpl);
  }

  @override
  String toWriterString() {
    StringBuffer _buffer = new StringBuffer('');
    _fieldCaches.forEach((element) {
      _buffer.write(element.toWriterString());
    });
    _constructorCaches.forEach((element) {
      _buffer.write('$element');
    });

    _methodCaches.forEach((element) {
      _buffer.write(element.toWriterString());
    });

    String clsTpl =
        createClassTpl(className: className, content: _buffer.toString());
    return clsTpl;
  }
}

class MethodWriter extends IWriter {
  final String returnType;
  final bool isStatic;
  final String name;
  final List<FieldWriter> params;
  final bool isOverride;
  final bool isParamNamed;
  final bool isAsync;

  List<String> _contents = [];

  MethodWriter({
    this.returnType = '',
    this.isStatic = false,
    this.name,
    this.params = const [],
    this.isOverride = false,
    this.isParamNamed = true,
    this.isAsync = false,
  });

  void appendMethodContent(String content) {
    _contents.add('$content\r\n');
  }

  void appendSwitch(String switchOrigin, List<SwitchTplModel> models) {
    _contents.add(createSwitchTpl(switchOrigin, models));
  }

  @override
  String toWriterString() {
    StringBuffer _tmp = new StringBuffer('');
    params.forEach((element) {
      _tmp.write('${element.toMethodString()}');
    });

    StringBuffer _content = StringBuffer('');
    _contents.forEach((element) {
      _content.write(element);
    });

    String method = createMethodTpl(
        methodName: name,
        isStatic: isStatic,
        returnType: returnType,
        params: _tmp.toString(),
        isOverride: isOverride,
        isAsync: isAsync,
        methodContent: _content.toString(),
        isParamsNamed: isParamNamed);

    return method;
  }
}

class FieldWriter extends IWriter {
   String type;
   String name;
   bool isFinal;
   bool isStatic;
   bool isConst;
   dynamic defaultValue;
   bool isConstructorParamsAndHasThisField;
   dynamic value;

  FieldWriter({
    this.type,
    this.name,
    this.isFinal = false,
    this.isConst = false,
    this.isStatic = false,
    this.defaultValue,
    this.isConstructorParamsAndHasThisField = false,
    this.value,
  });

  @override
  String toWriterString() {
    StringBuffer _buffer = new StringBuffer('');
    if (isFinal) {
      _buffer.write('final ');
    }
    if (isStatic) {
      _buffer.write('static ');
    }
    if (isConst) {
      _buffer.write('const ');
    }
    _buffer.write('$type $name');
    if (value != null) {
      _buffer.write(' = $value');
    }
    _buffer.write(';');

    return _buffer.toString();
  }

  String toConstructorString() {
    if (isConstructorParamsAndHasThisField) {
      return 'this.$name,';
    }
    return '$type $name,';
  }

  String toMethodString() {
    StringBuffer _buffer = StringBuffer();
    if (isFinal) {
      _buffer.write('final ');
    }
    _buffer.write('$type $name');
    if (defaultValue != null) {
      _buffer.write(' = ${defaultValue.toString()}');
    }


    _buffer.write(',');

    return _buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldWriter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name;

  @override
  int get hashCode => type.hashCode ^ name.hashCode;
}

abstract class IWriter {
  String toWriterString();
}
