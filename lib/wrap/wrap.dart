import 'dart:ui';

import 'package:flutter/material.dart';

typedef WrapperWidgetBuilder(WrapperUtils util, BuildContext context);

class Wrapper extends StatefulWidget {
  final double designWidth;
  final double designHeight;
  final WrapperWidgetBuilder child;

  const Wrapper(
      {Key key,
      @required this.designWidth,
      @required this.designHeight,
      @required this.child})
      : assert(designWidth != null),
        assert(designHeight != null),
        super(key: key);

  static WrapperState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<WrapperState>());
  }

  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  double screenWidth = 0, screenHeight = 0;
  WrapperUtils _utils;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (screenHeight == 0 || screenWidth == 0) {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;
        if (screenWidth == 0 || screenHeight == 0) {
          var defaultMetricsChanged = window.onMetricsChanged;
          window.onMetricsChanged = () {
            defaultMetricsChanged?.call();
            if (!window.physicalSize.isEmpty) {
              screenWidth = window.physicalSize.width / window.devicePixelRatio;
              screenHeight =
                  window.physicalSize.height / window.devicePixelRatio;
              _utils = WrapperUtils(screenWidth, screenHeight,
                  widget.designWidth, widget.designHeight);
              window.onMetricsChanged = defaultMetricsChanged;
              if (mounted) {
                setState(() {});
              }
            }
          };
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, con) {
      if (screenWidth == 0 || screenHeight == 0) {
        screenWidth = MediaQuery.of(ctx).size.width;
        screenHeight = MediaQuery.of(ctx).size.height;
      }
      if (_utils == null) {
        _utils = WrapperUtils(
            screenWidth, screenHeight, widget.designWidth, widget.designHeight);
      }

      return widget.child(_utils, ctx);
    });
  }

  double wrapWidth(double px) {
    return screenWidth / widget.designWidth * px;
  }

  double wrapHeight(double px) {
    return screenHeight / widget.designHeight * px;
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
