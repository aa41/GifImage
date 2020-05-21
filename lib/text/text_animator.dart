import 'package:flutter/material.dart';

class TextAnimatorWidget extends StatefulWidget {
  final Text text;

  final AnimationController controller;

  const TextAnimatorWidget(
      {Key key, @required this.text, @required this.controller})
      : super(key: key);

  @override
  _TextAnimatorWidgetState createState() => _TextAnimatorWidgetState();
}

class _TextAnimatorWidgetState extends State<TextAnimatorWidget> {
  String text = '';

  String _data = '';

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    text = widget.text.data;
    _controller = widget.controller;
    _controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(TextAnimatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text.data != widget.text.data) {
      text = widget.text.data;
    }

    if (oldWidget.controller != widget.controller) {
      _controller?.removeListener(_listener);
      _controller = widget.controller;
      _controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _data,
      style: widget.text.style,
      strutStyle: widget.text.strutStyle,
      textAlign: widget.text.textAlign,
      overflow: widget.text.overflow,
      locale: widget.text.locale,
      softWrap: widget.text.softWrap,
      textScaleFactor: widget.text.textScaleFactor,
    );
  }

  void _listener() {
    int length = text.length;
    _data = text.substring(0, (length * _controller.value).floor());
    setState(() {});
  }
}
