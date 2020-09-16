import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BiliBiliBanner extends StatefulWidget {
  @override
  _BiliBiliBannerState createState() => _BiliBiliBannerState();
}

class _BiliBiliBannerState extends State<BiliBiliBanner> {
  PageController controller = new PageController(viewportFraction: 0.5);
  List<Widget> children = [];
  
  double startDx,startDy,updateDx,updateDy;
  
  double offsetFraction = 0.0;
  

  double width = 100.0;
  @override
  void initState() {
    super.initState();
    children.add(Container(
      color: Colors.red,
      width: 100,
      height: 100,
    ));
    children.add(Container(
      color: Colors.blue,
      width: 100,
      height: 100,
    ));
    children.add(Container(
      color: Colors.green,
      width: 100,
      height: 100,
    ));
    children.add(Container(
      color: Colors.yellow,
      width: 100,
      height: 100,
    ));
    
   
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _onHorizontalDragDown,
      onPanStart: _onHorizontalDragStart,
      onPanUpdate: _onHorizontalDragUpdate,
      onPanEnd: _onHorizontalDragEnd,
      onPanCancel: _onHorizontalDragCancel,
      child: LayoutBuilder(builder: (context,cons){
        width = cons.maxWidth;
        return Stack(
          children: children.map((e) {
            int index = children.indexOf(e);
            double angle = 360 / (children.length) * index;
            double nag = (angle >180 ?-1 :1);
            double fraction =nag* ((angle - 180)%180)/90.0;
            double scale =1.0 -(fraction.abs() * offsetFraction.abs())%1.0 ;
            double dx = (fraction+offsetFraction) * width;
            print("fraction----!!!!$scale------$index");
            return Transform.translate(
              offset: Offset(dx, 0),
              child: Transform.scale(
                  scale: scale,
                  child: e),
            );
          }).toList(),
        );
      }),
    );
  }

  void _onHorizontalDragDown(DragDownDetails details) {
    startDx = details.localPosition.dx;
    startDy  = details.localPosition.dy;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDx = details.localPosition.dx;
    startDy  = details.localPosition.dy;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    updateDx = details.localPosition.dx;
    updateDy = details.localPosition.dy;
    offsetFraction += ((updateDx -  startDx)/width).clamp(-1.0, 1.0);
    startDx = updateDx;
    startDy = updateDy;
   // print("offsetFraction--!${updateDx} !${startDx}------!!!${offsetFraction}");
    setState(() {});
    
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    
  }

  void _onHorizontalDragCancel() {}
}
