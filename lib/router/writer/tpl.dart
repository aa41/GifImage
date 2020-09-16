String createConstructorTpl(
    {String className,
    bool hasSuper = false,
    bool isConst = true,
    String superContent = '',
    String params = '',
    bool isParamsNamed = true}) {
  String tpl = '''
 
  ${isConst ? 'const' : ''} $className(${_createParamsNamed(isParamsNamed, params)})${hasSuper ? ':super($superContent});' : ''};
  ''';

  return tpl;
}

String createSwitchTpl(String switchOrigin, List<SwitchTplModel> switchCase) {
  if (switchCase == null || switchCase.isEmpty) return '';
  String switchContent = switchCase.fold<String>('', (previousValue, element) {
    String _cases = '';
    if (element.switchCases != null && switchCase.isNotEmpty) {
      _cases = element.switchCases.fold<String>('', (previousValue, e) {
        previousValue += 'case "$e":\r\n';
        return previousValue;
      });
    }

    String _tpl = '''
    case '${element.switchValue}':
    $_cases
      ${element.switchContent ?? ''}
    break;
    ''';
    previousValue += _tpl;
    return previousValue;
  });
  String tpl = '''
  
    switch($switchOrigin){
     ${switchContent ?? ''}   
    }
  ''';

  return tpl;
}

String createInitializeTpl({
  String className,
  String params,
}) {
  String tpl = '''
  $className ( $params )
  ''';

  return tpl;
}

String createClassTpl(
    {String className,
    String extendsClassName,
    bool isAbstract = false,
    List<String> withMixin = const [],
    List<String> impl = const [],
    String content}) {
  String mixin;
  if (withMixin == null || withMixin.isEmpty) {
    mixin = '';
  } else {
    mixin = withMixin.fold<String>('', (previousValue, element) {
      return previousValue + element + ",";
    });
    mixin = mixin.substring(0, mixin.length - 1);
  }
  String imp;

  if (impl == null || impl.isEmpty) {
    imp = '';
  } else {
    imp = impl.fold<String>('', (previousValue, element) {
      return previousValue + element + ",";
    });
    imp = imp.substring(0, imp.length - 1);
  }
  String tpl = '''
  ${isAbstract ? 'abstract' : ''}class $className ${extendsClassName == null ? '' : "extends $extendsClassName"} ${withMixin == null || withMixin.isEmpty ? '' : 'with $mixin'} ${impl == null || impl.isEmpty ? '' : 'implements $imp'}{
    $content
  }

  ''';
  return tpl;
}

String createMethodTpl(
    {String methodName,
    bool isStatic = false,
    String returnType,
    String params = '',
    bool isOverride = false,
    String methodContent = '',
    bool isAsync = false,
    bool isParamsNamed = true}) {
  String tpl = '''
  ${isOverride ? '@overrider' : ''}
  ${isStatic ? 'static' : ''} ${returnType ?? 'void'} $methodName(${_createParamsNamed(isParamsNamed, params)}) ${isAsync ? 'async' : ''}{
     $methodContent
  }
  ''';

  return tpl;
}

String _createParamsNamed(bool isParamsNamed, String params) {
  bool isNotEmpty = isParamsNamed && params != null && params.isNotEmpty;
  return '${isNotEmpty ? '{' : ''}$params ${isNotEmpty ? '}' : ''}';
}

String createExtension(
    {String extensionName, String extensionType, String content = ''}) {
  return '''
  
  extension $extensionName on $extensionType{
  $content
}
  ''';
}

class SwitchTplModel {
  final String switchValue;
  final String switchContent;
  final List<String> switchCases;

  SwitchTplModel(this.switchValue, this.switchContent, {this.switchCases});
}
