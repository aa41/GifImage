import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gif_image/banner/banner.dart';
import 'package:gif_image/dialog_manager/dialog.dart';
import 'package:gif_image/navigator/route.dart';
import 'package:gif_image/router/router_provider.dart';
import 'package:gif_image/text/text_animator.dart';
import 'package:gif_image/widget/round_fade.dart';
import 'package:gif_image/widget/test.dart';
import 'package:gif_image/wrap/wrap.dart';
import 'package:gif_image/track/track.dart';
import 'image/Image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [],
      title: 'Flutter Demo',
      onGenerateRoute: (settings){
        return MXCRouter.instance.onGenerateRoute(settings);
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController _controller;
  int count = 200;
  ScrollIndexController _scrollIndexController;

  void _incrementCounter() {
    count = Random().nextInt(1000);
    int random = Random().nextInt(count);
    print("index:${random}");
    _scrollIndexController.jumpToIndex(random,offset: 50);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollIndexController = new ScrollIndexController();
    defaultScrollTrackListener = (itemContext) {
      print("scroll-------${itemContext.index}");
    };
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5000));
    _controller.forward(from: 0.0);
    

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
        child:  RoundFadeImage(imageProvider: [AssetImage('assets/ycy_01.jpg'),AssetImage('assets/timg.jpeg'),AssetImage('assets/timg2.jpeg')],),
//           child: Wrapper(
//               designWidth: 500,
//               designHeight: 500,
//               child: (utils, ctx) {
//                 return Column(
//                   children: <Widget>[
//
// //              Container(
// //                width: utils.wrapWidth(200),
// //                height: utils.wrapHeight(200),
// //                color: Colors.red,
// //                child: TextAnimatorWidget(
// //                  text: Text('飞流直下三千尺,飞流直下三千尺,飞流直下三千尺,飞流直下三千尺,飞流直下三千尺,飞流直下三千尺',style: TextStyle(fontSize: 16,color: Colors.white),),
// //                  controller: _controller,
// //                ),
// //              ),
// //              Container(
// //                width: 100,
// //                height: 100,
// //                child: NativeImage(),
// //              ),
//
//
//                   Expanded(child: BiliBiliBanner()),

//                    Expanded(
//                        child: ScrollTrack(
//                      child: ListView.builder(
//                        controller: _scrollIndexController,
//                        itemBuilder: (context, index) {
//                          return TrackItem(
//                            index: index,
//                            child: InkWell(
//                              onTap: (){
//                                Navigator.of(context).push(AnimateRoute((context){
//                                  return Scaffold(body: Container(child:
//                                  ListView.builder(
//
//                                    itemBuilder: (context, index) {
//                                      return TrackItem(
//                                        index: index,
//                                        child: Container(
//                                          height: 100,
//                                          child: Center(
//                                            child: Text(
//                                              "index:$index",
//                                              style: TextStyle(
//                                                  color: Colors.white, fontSize: 20),
//                                            ),
//                                          ),
//                                          color: index % 2 == 0 ? Colors.red : Colors.blue,
//                                        ),
//                                      );
//                                    },
//                                    itemCount: count,
//                                  )
//                                  )
//                                    ,);
//                                }));
//                              },
//                              child: Container(
//                                height: 100,
//                                child: Center(
//                                  child: Text(
//                                    "index:$index",
//                                    style: TextStyle(
//                                        color: Colors.white, fontSize: 20),
//                                  ),
//                                ),
//                                color: index % 2 == 0 ? Colors.red : Colors.blue,
//                              ),
//                            ),
//                          );
//                        },
//                        itemCount: count,
//                      ),
//                    ))
//                   ],
//                 );
//               })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
