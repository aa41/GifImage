import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class RoundFadeImage extends StatefulWidget {
  final List<ImageProvider> imageProvider;

  const RoundFadeImage({
    Key key,
    this.imageProvider,
  }) : super(key: key);

  @override
  _RoundFadeImageState createState() => _RoundFadeImageState();
}

class _RoundFadeImageState extends State<RoundFadeImage>
    with TickerProviderStateMixin {
  List<ImageInfo> _imageInfos = [];
  List<List<Round>> balls = [];
  List<Uint8List> _pngDatas = [];
  int index = 0;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _initProvider();
    _controller.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          if (index >= widget.imageProvider.length- 1) {
            return;
          }else{
            Future.delayed(Duration(milliseconds: 500),(){
              index++;
              _controller.forward(from: 0.0);
            });

          }

          break;
      }
    });
  }

  void _initProvider() {
    Future.delayed(Duration(milliseconds: 0), () {
      preloadImageListByte(widget.imageProvider, context).then((values) async {
        _imageInfos = values;
        awaitSource(values).listen((event) {
          if(event == widget.imageProvider.length-1){
            _controller.forward(from: 0.0);

          }
        });
      });
      // preloadImageByte(
      //   widget.imageProvider,
      //   context,
      // ).then((value) async {
      //
      //   _controller.forward(from: 0.0);
      // });
    });
  }

  Stream<int> awaitSource(List<ImageInfo> values) async* {
    for (int i = 0; i < values.length; i++) {
      var value = values[i];
      if (value != null) {
        Uint8List _originImageData = await value.image
            .toByteData(format: ImageByteFormat.rawRgba)
            .then((value) => Uint8List.view(value.buffer));
        var _pngData = await value.image
            .toByteData(format: ImageByteFormat.png)
            .then((value) => Uint8List.view(value.buffer));
        _pngDatas.add(_pngData);
        var size = MediaQuery.of(context).size;
        List<List<int>> colors = _createPixelArray(
            _originImageData, (value.image.width * value.image.height), 1);
        int i = 0;
        List<Round> _ball = [];
        while (i < colors.length) {
          double ratio = ((size.width * size.height * 1.0) / colors.length);
          double offsetY = i * ratio / size.width;
          double offsetX = (i * ratio * 1.0) % size.width;
          List<int> color = colors[i];
          Color c = Color.fromARGB(255, color[0], color[1], color[2]);
          i += Random().nextInt(200) + 1000;
          int radius = max(20, Random().nextInt(60));
          _ball.add(Round()
            ..offsetX = offsetX
            ..offsetY = offsetY
            ..color = c
            ..radius = radius);
        }
        balls.add(_ball);
      }
      yield i;
    }
  }

  List<List<int>> _createPixelArray(
      Uint8List imgData, int pixelCount, int quality) {
    final pixels = imgData;
    List<List<int>> pixelArray = [];

    for (var i = 0, offset, r, g, b, a; i < pixelCount; i = i + quality) {
      offset = i * 4;
      r = pixels[offset + 0];
      g = pixels[offset + 1];
      b = pixels[offset + 2];
      a = pixels[offset + 3];

      if (!(r > 250 && g > 250 && b > 250)) {
        pixelArray.add([r, g, b]);
      }
    }
    return pixelArray;
  }

  @override
  void didUpdateWidget(RoundFadeImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      //  _initProvider();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Transform.scale(
          scale: 1.5 + (1.0 * (1.0 - _controller.value)),
          child: Transform.rotate(
            angle: pi * 0.25 * (1 - _controller.value),
            child: Stack(fit: StackFit.expand, children: <Widget>[
              _imageInfos == null || _imageInfos.isEmpty
                  ? Container()
                  : Container(
                      // child: Image(
                      //   image: widget.imageProvider,
                      //   fit: BoxFit.cover,
                      // ),
                      child: Image.memory(
                        _pngDatas[index],
                        fit: BoxFit.cover,
                      ),
                    ),
              _imageInfos == null || _imageInfos.isEmpty
                  ? Container()
                  : CustomPaint(
                      painter: RoundBall(
                          controller: _controller, rounds: balls[index]),
                    )
            ]),
          )),
      onTap: () {
        index = 0;
        _controller.forward(from: 0.0);
      },
    );
  }
}

Future<List<ImageInfo>> preloadImageListByte(
  List<ImageProvider> provider,
  BuildContext context, {
  Size size,
  ImageErrorListener onError,
}) async {
  List<ImageInfo> infos = [];
  int index = 0;
  while (index < provider.length) {
    ImageInfo info = await preloadImageByte(provider[index], context,
        size: size, onError: onError);
    index++;
    if (info != null) {
      infos.add(info);
    }
  }
  print('info----${infos.length}');
  return infos;
}

Future<ImageInfo> preloadImageByte(
  ImageProvider provider,
  BuildContext context, {
  Size size,
  ImageErrorListener onError,
}) {
  final ImageConfiguration config =
      createLocalImageConfiguration(context, size: size);
  final Completer<ImageInfo> completer = Completer<ImageInfo>();
  final ImageStream stream = provider.resolve(config);
  ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo image, bool sync) async {
      if (!completer.isCompleted) {
        completer.complete(image);
      }

      // Give callers until at least the end of the frame to subscribe to the
      // image stream.
      // See ImageCache._liveImages
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        stream.removeListener(listener);
      });
    },
    onError: (dynamic exception, StackTrace stackTrace) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      stream.removeListener(listener);
      if (onError != null) {
        onError(exception, stackTrace);
      } else {
        FlutterError.reportError(FlutterErrorDetails(
          context: ErrorDescription('image failed to precache'),
          library: 'image resource service',
          exception: exception,
          stack: stackTrace,
          silent: true,
        ));
      }
    },
  );
  stream.addListener(listener);
  return completer.future;
}

class RoundBall extends CustomPainter {
  final AnimationController controller;

  final List<Round> rounds;

  RoundBall({this.controller, this.rounds}) : super(repaint: controller);

  Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (rounds == null || rounds.isEmpty) return;
    if (controller.value >= 1.0 || controller.value <= 0.0) return;

    for (int i = 0; i < rounds.length; i++) {
      Round round = rounds[i];
      _paint.color = round.color.withOpacity(1 - controller.value);
      canvas.drawCircle(Offset(round.offsetX, round.offsetY),
          (1 - controller.value) * round.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(RoundBall oldDelegate) {
    return controller.value != oldDelegate.controller.value ||
        rounds != oldDelegate.rounds;
  }
}

class Round {
  double offsetX;
  double offsetY;
  Color color;
  int radius;
}
