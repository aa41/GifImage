import 'package:flutter/material.dart';
import 'package:gif_image/router/router_provider.dart';
import 'package:gif_image/text/test_write.route.internal_invalid.dart';

import '../router/m_router.dart';


@MRouter(aliasNames: [
  '1',
  '2'
], params: {
  'a1': '2',
  'a2': 3,
  'a3': {'1': 2, '3': '4'},
  'a4': ClsFieldInfo(package: 'package:gif_image/widget/test.dart', clsName: 'A')
}, url: 'home/mine')
class Test3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Text(context.argumentsHomeMine().$a3.toString());
  }
}


