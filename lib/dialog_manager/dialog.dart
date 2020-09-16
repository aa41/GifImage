import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef Future<T> DialogFunc<T>();

class DialogManager {
  static Map<DialogManager, List<PopupRoute<dynamic>>> _popRoutersCaches = {};

  static bool isRegisterObserver = false;

  Map<int, Future<DialogFunc>> _dialogCaches = {};
  List<int> propertyQueue = [];

  static _DialogManagerRouterObserver _observer =
      new _DialogManagerRouterObserver();

  DialogManager() {
    _popRoutersCaches[this] = [];
  }

  static DialogManager _current;

  static _DialogManagerRouterObserver get observer => observer;

  static DialogManager get current => _current;

  void addSyncProperty(int property, DialogFunc function) {
    if (_dialogCaches[property] != null) {
      int tmpProperty = property;
      while (_dialogCaches[tmpProperty] == null) {
        tmpProperty--;
      }
      Completer<DialogFunc> func = Completer();
      _dialogCaches[tmpProperty] = func.future;
      propertyQueue.add(tmpProperty);
      func.complete(function);
    } else {
      Completer<DialogFunc> func = Completer();
      _dialogCaches[property] = func.future;

      propertyQueue.add(property);
      func.complete(function);
    }
    propertyQueue.sort();
  }

  Future<Function> addAsyncProperty(
      int property, Future future, DialogFunc function) async {
    Completer<DialogFunc> completer = Completer();
    future.whenComplete(() {
      completer.complete(function);
    }).catchError((err) {
      removeProperty(property);
      completer.completeError(err);
    });
    Future newFuture = completer.future;
    _addFuture(property, newFuture);
    return newFuture;
  }

  void _addFuture(int property, Future<DialogFunc> future) async {
    if (_dialogCaches[property] != null) {
      int tmpProperty = property;
      while (_dialogCaches[tmpProperty] == null) {
        tmpProperty--;
      }
      _dialogCaches[tmpProperty] = future;
      propertyQueue.add(tmpProperty);
    } else {
      _dialogCaches[property] = future;
      propertyQueue.add(property);
    }
    propertyQueue.sort();
  }

  void attachContext(BuildContext context) {
    if (TickerMode.of(context)) {
      _current = this;
    }
  }

  void show() {
    if (_dialogCaches.isNotEmpty) {
      Future<DialogFunc> future = _dialogCaches[propertyQueue.last];
      future.then((func) {
        func.call();
      }).catchError((err) {
        removeLast();
        show();
      });
    }
  }

  void _addCacheDialog(PopupRoute<dynamic> route) {
    _popRoutersCaches[current]?.add(route);
  }

  void _removeCacheDialog(PopupRoute<dynamic> route) {
    _popRoutersCaches[current]?.remove(route);
  }

//  @override
//  void didPush(Route route, Route previousRoute) {
//    super.didPush(route, previousRoute);
//    print("push-------${route.runtimeType}----${previousRoute.runtimeType}");
//    if (route is PopupRoute) {
//      popRouters.add(route);
//    }
//  }
//
//  @override
//  void didPop(Route route, Route previousRoute) {
//    super.didPop(route, previousRoute);
//    print("pop-------${route.runtimeType}----${previousRoute.runtimeType}");
//    if (route is PopupRoute && popRouters.isNotEmpty) {
//      dismiss();
//      popRouters.remove(route);
//    }
//  }

  void dismiss() {
    if (_dialogCaches.isNotEmpty) {
      removeLast();
      show();
    }
  }

  void removeLast() {
    int lastProperty = propertyQueue.removeLast();
    _dialogCaches.remove(lastProperty);
  }

  void removeProperty(int property) {
    propertyQueue.remove(property);
    _dialogCaches.remove(property);
  }

  void dispose() {
    _dialogCaches.clear();
    propertyQueue.clear();
    isRegisterObserver = false;
    _current = null;
  }
}

class _DialogManagerRouterObserver extends NavigatorObserver {
  bool isStartListen = false;
  
  
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    isStartListen = route is PopupRoute;
    if (isStartListen) {
      DialogManager.current._addCacheDialog(route);
    }
  }

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PopupRoute) {
      DialogManager.current.dismiss();
      DialogManager.current._removeCacheDialog(route);
    }
  }
}
