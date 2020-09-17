import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:gif_image/router/utils/utils.dart';
import 'package:gif_image/text/test_write.route.internal_invalid.dart';

abstract class IRouterProvider {
  Future<T> pushName<T>(BuildContext context, String routeName,
      {Object arguments});

  Future<T> pushNamedAndRemoveUntil<T>(
      BuildContext context, String newRouteName, RoutePredicate predicate,
      {Object arguments});

  Future<T> pushReplacementNamed<T>(BuildContext context, String routeName,
      {Object arguments});

  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
    BuildContext context,
    String routeName, {
    TO result,
    Object arguments,
  });

  Future<T> argumentsAsync<T>(BuildContext context);

  T arguments<T>(BuildContext context);


  Route<dynamic> injectGenerateRoute(RouteSettings settings);

  Widget buildNotFoundWidget(RouteSettings settings);

  Route<dynamic> buildCustomRoute(
      String url, dynamic arguments, WidgetBuilder builder);
}

class MXCRouter {
  static MXCRouter _instance = MXCRouter();

  static MXCRouter get instance => _instance;

  IRouterProvider _provider;

  void registerRouterProvider(IRouterProvider provider) {
    this._provider = provider;
  }

  void init() {
    _provider = _DefaultRouterProvider();
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return mxcOnGenerateRoute(settings);
  }

  IRouterProvider get provider {
    _provider ??= _DefaultRouterProvider();
    return _provider;
  }
}

class _DefaultRouterProvider extends IRouterProvider {
  @override
  Route buildCustomRoute(String url, dynamic arguments, WidgetBuilder builder) {
    return MaterialPageRoute(
        builder: builder,
        settings: RouteSettings(name: url, arguments: arguments));
  }

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
      BuildContext context, String routeName,
      {TO result, Object arguments}) {
    return Navigator.popAndPushNamed<T,TO>(context, routeName,
        result: result, arguments: arguments);
  }

  @override
  Future<T> pushName<T>(BuildContext context, String routeName,
      {Object arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  @override
  Future<T> pushNamedAndRemoveUntil<T>(
      BuildContext context, String newRouteName, predicate,
      {Object arguments}) {
    return Navigator.pushNamedAndRemoveUntil(context, newRouteName, predicate,
        arguments: arguments);
  }

  @override
  Future<T> pushReplacementNamed<T>(BuildContext context, String routeName,
      {Object arguments}) {
    return Navigator.pushReplacementNamed(context, routeName,
        arguments: arguments);
  }

  @override
  T arguments<T>(BuildContext context) {
    return ModalRoute?.of(context)?.settings?.arguments;
  }

  @override
  Future<T> argumentsAsync<T>(BuildContext context) async {
    if (ModalRoute?.of(context)?.settings?.arguments == null) {
      await SchedulerBinding.instance.endOfFrame;
      return ModalRoute?.of(context)?.settings?.arguments;
    }
    return ModalRoute?.of(context)?.settings?.arguments;
  }

  @override
  Widget buildNotFoundWidget(RouteSettings settings) {
    return ErrorWidget('not found ${settings.name}');
  }

  @override
  Route injectGenerateRoute(RouteSettings settings) {
    return null;
  }


}

extension MXCContext on BuildContext {
  IRouterProvider get routerProvider => MXCRouter.instance.provider;
}
