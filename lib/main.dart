import 'package:flutter/material.dart';
import 'package:gif_image/text/text_animator.dart';
import 'package:gif_image/wrap/wrap.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  void _incrementCounter() {
    _controller.reverse(from: 1.0);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 5000));
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Wrapper(designWidth: 500, designHeight: 500, child: (utils,ctx){
          return Container(
            width: utils.wrapWidth(200),
            height: utils.wrapHeight(200),
            color: Colors.red,
            child: TextAnimatorWidget(
              text: Text('飞流直下三千尺,飞流直下三千尺,飞流直下三千尺,飞流直下三千尺,飞流直下三千尺,飞流直下三千尺',style: TextStyle(fontSize: 16,color: Colors.white),),
              controller: _controller,
            ),
          );
        })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
