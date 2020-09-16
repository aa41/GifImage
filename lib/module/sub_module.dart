import 'package:flutter/material.dart';
import 'package:gif_image/module/main_module.dart';

typedef Widget MaterialAppBuilder(MaterialApp app);

class SubManager {
  static SubManager _instance = SubManager._();

  static SubManager get instance => _instance;

  SubManager._();

  Map<String, SubModule> _modules = {};

  void registerSubModule(SubModule subModule) {
    _modules.putIfAbsent(subModule.subName, () {
      return subModule;
    });
  }

  void removeSubModule(SubModule subModule) {
    _modules.remove(subModule.subName);
  }

  Route<dynamic> handleSubRoute(RouteSettings settings) {
    if (_modules.isEmpty) return null;
    var it = _modules.entries.iterator;

    while (it.moveNext()) {
      SubModule subModule = it.current.value;

      MaterialApp app = subModule.app;

      Route<dynamic> route = app.onGenerateRoute(settings);
      if (route != null) {
        return route;
      }
    }
    return null;
  }

  List<NavigatorObserver> collectObservers() {
    List<NavigatorObserver> obs = [];
    if (_modules.isEmpty) return obs;
    var it = _modules.entries.iterator;
    while (it.moveNext()) {
      SubModule subModule = it.current.value;
      MaterialApp app = subModule.app;
      List<NavigatorObserver> subObs = app.navigatorObservers;
      obs.addAll(subObs ?? []);
    }
    return obs;
  }

  void clear() {
    _modules.clear();
  }
}

class SubModule {
  final MaterialApp app;
  final String subName;

  SubModule({@required this.app, @required this.subName});

  void init() {
    SubManager.instance.registerSubModule(this);
  }
}

class SubInheritedWidget extends InheritedWidget {
  final SubModule subModule;

  const SubInheritedWidget(
      {Key key, @required Widget child, @required this.subModule})
      : assert(child != null),
        super(key: key, child: child);

  static SubInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SubInheritedWidget>();
  }

  @override
  bool updateShouldNotify(SubInheritedWidget old) {
    return subModule != old.subModule;
  }
}

class SubModuleWidget extends StatefulWidget {
  final MaterialAppBuilder builder;
  final SubModule subModule;

  const SubModuleWidget({Key key, this.builder, this.subModule})
      : super(key: key);

  @override
  _SubModuleWidgetState createState() => _SubModuleWidgetState();
}

class _SubModuleWidgetState extends State<SubModuleWidget> {
  bool isInMainModule;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isInMainModule == null) {
      isInMainModule = MainModuleInherited.isInMainModule(context);
    }
    if (isInMainModule) {
      return Container();
    } else {
      Widget result = widget.subModule.app;
      if (widget.builder != null) {
        result = widget.builder(result);
      }
      return result;
    }
  }
}
