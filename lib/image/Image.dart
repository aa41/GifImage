import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeImage extends StatefulWidget {
  @override
  _NativeImageState createState() => _NativeImageState();
}

class _NativeImageState extends State<NativeImage> {
  int _id;

  @override
  void initState() {
    super.initState();
    NativeImageManager.requestNativeTextureId('drawable', 'ic_launcher')
        .then((value) {
      setState(() {
        _id = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _id == null ? Container() : Texture(textureId: _id);
  }
}

class NativeImageManager {
  static Map<String, int> _cacheTextureId = LinkedHashMap();

  static MethodChannel channel = MethodChannel("flutter_native");

  static Future<int> requestNativeTextureId(String type, String path) async {
    String key = '$type-$path';
    if (_cacheTextureId.containsKey(key)) {
      return _cacheTextureId[key];
    }
    int _textureId =
        await channel.invokeMethod('nativeImage', {'type': type, "path": path});
    return _cacheTextureId.putIfAbsent(key, () {
      return _textureId;
    });

  }
}
