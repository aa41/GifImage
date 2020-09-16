
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimateRoute extends PageRoute {
  final WidgetBuilder builder;

  AnimateRoute(this.builder);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
  
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    print("value-----${animation.value}----${secondaryAnimation.value}");
    if(animation.value  == 1.0){
      return child;
    }
   print("context.findRenderObject().runtimeType-----${context.findRenderObject().runtimeType}");
   return Stack(
     children: <Widget>[
       child,
       Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40,sigmaY: 40,),child: Container(color: Colors.white.withOpacity(animation.value * 0.25)),)),
     ],
   );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(parent: super.createAnimation(), curve: Curves.easeInCirc);
  }

  @override
  AnimationController createAnimationController() {
    return super.createAnimationController();
  }
}
