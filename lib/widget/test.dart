import 'package:flutter/material.dart';
import 'package:gif_image/text/test_write.route.internal_invalid.dart';

import '../router/m_router.dart';


@MRouter(aliasNames: [
  '/',
], params: {
  'a1': '2',
  'a2': 3,
  'a3': {'1': 2, '3': '4'},
  'a4': ClsFieldInfo(package: 'package:gif_image/widget/test.dart', clsName: 'A')
}, url: 'main')
class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: (){
            context.pushNameToHomeMine($a1: '111',$a2: 2,$a3: {'1':2},$a4: A());

          },
          child: Text('taptap'),

        ),
      ),
    );
  }
}


class A {
  final String a;
  final String B;

  const A({this.a, this.B});
}

