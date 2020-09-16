import 'package:flutter/material.dart';

class MainModuleInherited extends InheritedWidget {
  const MainModuleInherited({
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static MainModuleInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainModuleInherited>();
  }

  static bool isInMainModule(BuildContext context) {
    return of(context) != null;
  }

  @override
  bool updateShouldNotify(MainModuleInherited old) {
    return false;
  }






}
