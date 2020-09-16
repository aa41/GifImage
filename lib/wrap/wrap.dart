import 'dart:ui';

import 'package:flutter/material.dart';

typedef WrapperWidgetBuilder(WrapperUtils util, BuildContext context);

class Wrapper extends StatefulWidget {
  final double designWidth;
  final double designHeight;
  final WrapperWidgetBuilder child;
  final bool isAutoScreen;

  const Wrapper(
      {Key key,
      @required this.designWidth,
      @required this.designHeight,
      @required this.child,
      this.isAutoScreen = true})
      : assert(designWidth != null),
        assert(designHeight != null),
        super(key: key);

  static WrapperUtils of(BuildContext context) {
    return (context.ancestorStateOfType(TypeMatcher<WrapperState>())
            as WrapperState)
        ?.utils;
  }

  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  double _currWidth = 0, _currHeight = 0;
  WrapperUtils _utils;
  Function defaultMetricsChanged;

  @override
  void initState() {
    super.initState();
    defaultMetricsChanged = window.onMetricsChanged;
    window.onMetricsChanged = () {
      defaultMetricsChanged?.call();
      if (!window.physicalSize.isEmpty) {
        if (widget.isAutoScreen) {
          _currWidth = window.physicalSize.width / window.devicePixelRatio;
          _currHeight = window.physicalSize.height / window.devicePixelRatio;
        } else {
          _currWidth = context.size.width;
          _currHeight = context.size.height;
        }

        _utils = WrapperUtils(
            _currWidth, _currHeight, widget.designWidth, widget.designHeight);
        if (mounted) {
          setState(() {});
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, con) {
      if (_currWidth == 0 || _currHeight == 0) {
        if (widget.isAutoScreen) {
          _currWidth = MediaQuery.of(ctx).size.width;
          _currHeight = MediaQuery.of(ctx).size.height;
        } else {
          _currWidth = con.minWidth;
          _currHeight = con.minHeight;
        }
      }
      if (_utils == null) {
        _utils = WrapperUtils(
            _currWidth, _currHeight, widget.designWidth, widget.designHeight);
      }

      return widget.child(_utils, ctx);
    });
  }

  WrapperUtils get utils => _utils;

  @override
  void dispose() {
    window.onMetricsChanged = defaultMetricsChanged;
    super.dispose();
  }
}

class WrapperUtils {
  final double screenWidth;
  final double screenHeight;
  final double designWidth;
  final double designHeight;

  WrapperUtils(
    this.screenWidth,
    this.screenHeight,
    this.designWidth,
    this.designHeight,
  );

  double wrapWidth(double px) {
    return screenWidth / designWidth * px;
  }

  double wrapHeight(double px) {
    return screenHeight / designHeight * px;
  }
}
