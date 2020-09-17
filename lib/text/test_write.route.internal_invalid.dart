// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: MXCWriteRouterGen
// **************************************************************************

import 'package:gif_image/widget/test2.dart';
import 'package:gif_image/widget/test3.dart';
import 'package:gif_image/widget/test.dart';
import 'package:flutter/material.dart';
import 'package:gif_image/router/router_provider.dart';

Route<dynamic> mxcOnGenerateRoute(
  RouteSettings settings,
) {
  if (MXCRouter.instance.provider.buildNotFoundWidget(settings) != null) {
    return MXCRouter.instance.provider.injectGenerateRoute(settings);
  }

  switch (settings.name) {
    case 'home/index':
    case "1":
    case "2":
      return MXCRouter.instance.provider
          .buildCustomRoute("home/index", settings.arguments, (context) {
        return Test2();
      });

      break;
    case 'home/mine':
    case "1":
    case "2":
      return MXCRouter.instance.provider
          .buildCustomRoute("home/mine", settings.arguments, (context) {
        return Test3();
      });

      break;
    case 'main':
    case "/":
      return MXCRouter.instance.provider
          .buildCustomRoute("main", settings.arguments, (context) {
        return Test();
      });

      break;
  }
  return MXCRouter.instance.provider
      .buildCustomRoute(settings.name, settings.arguments, (context) {
    return MXCRouter.instance.provider.buildNotFoundWidget(settings);
  });
}

class $HomeIndexModel {
  final String $a1;
  final int $a2;
  final Map<String, dynamic> $a3;
  const $HomeIndexModel({
    this.$a1,
    this.$a2,
    this.$a3,
  });
}

class $HomeMineModel {
  final String $a1;
  final int $a2;
  final Map<String, dynamic> $a3;
  const $HomeMineModel({
    this.$a1,
    this.$a2,
    this.$a3,
  });
}

class $MainModel {
  final String $a1;
  final double $a2;
  final Map<String, dynamic> $a3;
  final A $a5;
  const $MainModel({
    this.$a1,
    this.$a2,
    this.$a3,
    this.$a5,
  });
}

extension MXCRouterBuildContext on BuildContext {
  Future<T> argumentsAsync<T>() async {
    return this.routerProvider.argumentsAsync(this);
  }

  T arguments<T>() {
    return this.routerProvider.arguments(this);
  }

  Future<T> pushNameToHomeIndex<T>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
  }) {
    return this.routerProvider.pushName<T>(this, 'home/index',
        arguments: $HomeIndexModel($a1: $a1, $a2: $a2, $a3: $a3));
  }

  Future<T> pushReplacementNamedToHomeIndex<T>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
  }) {
    return this.routerProvider.pushReplacementNamed<T>(this, 'home/index',
        arguments: $HomeIndexModel($a1: $a1, $a2: $a2, $a3: $a3));
  }

  Future<T> popAndPushNamedToHomeIndex<T, T0>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
    T0 result,
  }) {
    return this.routerProvider.popAndPushNamed<T, T0>(this, 'home/index',
        arguments: $HomeIndexModel($a1: $a1, $a2: $a2, $a3: $a3),
        result: result);
  }

  Future<T> pushNamedToHomeIndexAndRemoveUntil<T>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
    RoutePredicate predicate,
  }) {
    return this.routerProvider.pushNamedAndRemoveUntil(
        this, 'home/index', predicate,
        arguments: $HomeIndexModel($a1: $a1, $a2: $a2, $a3: $a3));
  }

  Future<$HomeIndexModel> argumentsAsyncHomeIndex() async {
    return argumentsAsync<$HomeIndexModel>();
  }

  $HomeIndexModel argumentsHomeIndex() {
    return arguments<$HomeIndexModel>();
  }

  Future<T> pushNameToHomeMine<T>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
  }) {
    return this.routerProvider.pushName<T>(this, 'home/mine',
        arguments: $HomeMineModel($a1: $a1, $a2: $a2, $a3: $a3));
  }

  Future<T> pushReplacementNamedToHomeMine<T>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
  }) {
    return this.routerProvider.pushReplacementNamed<T>(this, 'home/mine',
        arguments: $HomeMineModel($a1: $a1, $a2: $a2, $a3: $a3));
  }

  Future<T> popAndPushNamedToHomeMine<T, T0>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
    T0 result,
  }) {
    return this.routerProvider.popAndPushNamed<T, T0>(this, 'home/mine',
        arguments: $HomeMineModel($a1: $a1, $a2: $a2, $a3: $a3),
        result: result);
  }

  Future<T> pushNamedToHomeMineAndRemoveUntil<T>({
    final String $a1,
    final int $a2,
    final Map<String, dynamic> $a3,
    RoutePredicate predicate,
  }) {
    return this.routerProvider.pushNamedAndRemoveUntil(
        this, 'home/mine', predicate,
        arguments: $HomeMineModel($a1: $a1, $a2: $a2, $a3: $a3));
  }

  Future<$HomeMineModel> argumentsAsyncHomeMine() async {
    return argumentsAsync<$HomeMineModel>();
  }

  $HomeMineModel argumentsHomeMine() {
    return arguments<$HomeMineModel>();
  }

  Future<T> pushNameToMain<T>({
    final String $a1,
    final double $a2,
    final Map<String, dynamic> $a3,
    final A $a5,
  }) {
    return this.routerProvider.pushName<T>(this, 'main',
        arguments: $MainModel($a1: $a1, $a2: $a2, $a3: $a3, $a5: $a5));
  }

  Future<T> pushReplacementNamedToMain<T>({
    final String $a1,
    final double $a2,
    final Map<String, dynamic> $a3,
    final A $a5,
  }) {
    return this.routerProvider.pushReplacementNamed<T>(this, 'main',
        arguments: $MainModel($a1: $a1, $a2: $a2, $a3: $a3, $a5: $a5));
  }

  Future<T> popAndPushNamedToMain<T, T0>({
    final String $a1,
    final double $a2,
    final Map<String, dynamic> $a3,
    final A $a5,
    T0 result,
  }) {
    return this.routerProvider.popAndPushNamed<T, T0>(this, 'main',
        arguments: $MainModel($a1: $a1, $a2: $a2, $a3: $a3, $a5: $a5),
        result: result);
  }

  Future<T> pushNamedToMainAndRemoveUntil<T>({
    final String $a1,
    final double $a2,
    final Map<String, dynamic> $a3,
    final A $a5,
    RoutePredicate predicate,
  }) {
    return this.routerProvider.pushNamedAndRemoveUntil(this, 'main', predicate,
        arguments: $MainModel($a1: $a1, $a2: $a2, $a3: $a3, $a5: $a5));
  }

  Future<$MainModel> argumentsAsyncMain() async {
    return argumentsAsync<$MainModel>();
  }

  $MainModel argumentsMain() {
    return arguments<$MainModel>();
  }
}
