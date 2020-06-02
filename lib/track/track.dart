import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

const TRACK_TAG = "Track:";

typedef void OnScrollTrackListener(ItemContext context);

OnScrollTrackListener defaultScrollTrackListener = (ItemContext itemContext) {};

class ScrollIndexController extends ScrollController {
  Future<void> jumpToIndex(int index, {double offset = 0.0}) async {
    await _awaitToNextFrame();
    if (scrollTrackState?.items == null ||
        (scrollTrackState?.items?.isEmpty ?? true)) return;

    ItemContext itemContext = containsIndex(index);
    if (itemContext != null) {
      if (itemContext.context != null) {
        await _awaitToJump(itemContext, offset);
      }
    } else {
      await _awaitNearToTarget(index);
      ItemContext itemContext = containsIndex(index);
      if (itemContext != null) {
        if (itemContext.context != null) {
          await _awaitToJump(itemContext, offset);
        }
      }
    }
  }

  Future _awaitToJump(ItemContext itemContext, double offset) async {
    RenderObject renderObject = itemContext.context.findRenderObject();
    if (renderObject != null && renderObject.attached) {
      double _currentOffset = _offsetToReveal(renderObject);
      await _jumpToTarget(_currentOffset, offset);
    }
  }

  Future<void> _jumpToTarget(double _currentOffset, double offset) async {
    if (_currentOffset + offset > position.maxScrollExtent) {
      jumpTo(position.maxScrollExtent);
    } else {
      jumpTo(_currentOffset + offset);
    }
  }

  Future<void> _awaitNearToTarget(int index) async {
    for (int i = 0; i < 180; i++) {
      int _min = _minIndex?.index ?? pow(2, 32);
      int _max = _maxIndex?.index ?? -1;
      if (index >= _min && index <= _max) {
        break;
      } else {
        if (index < _min) {
          await _awaitToJump(_minIndex, 0.0);
        } else if (index > _max) {
          await _awaitToJump(_maxIndex, 0.0);
        }
        await _awaitToNextFrame();
      }
    }
  }

  ItemContext get _minIndex {
    List<ItemContext> items = scrollTrackState?.items;
    if (items == null || items.isEmpty) return null;

    int _min = pow(2, 32);
    ItemContext _current;
    for (ItemContext itemContext in items) {
      _min = min(_min, itemContext.index);
      if (_min == itemContext.index) {
        _current = itemContext;
      }
    }

    return _current;
  }

  ItemContext get _maxIndex {
    List<ItemContext> items = scrollTrackState?.items;
    if (items == null || items.isEmpty) return null;

    int _max = -1;
    ItemContext _current;
    for (ItemContext itemContext in items) {
      _max = max(_max, itemContext.index);
      if (_max == itemContext.index) {
        _current = itemContext;
      }
    }

    return _current;
  }

  double _offsetToReveal(RenderObject renderObject) {
    RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    double _currentOffset =
        viewport.getOffsetToReveal(renderObject, 0.0).offset;
    return _currentOffset;
  }

  Future<void> _awaitToNextFrame() {
    return SchedulerBinding.instance.endOfFrame;
  }

  ItemContext containsIndex(int index) {
    List<ItemContext> items = scrollTrackState?.items;
    if (items == null || items.isEmpty) return null;
    for (ItemContext itemContext in items) {
      if (itemContext.index == index) {
        return itemContext;
      }
    }
    return null;
  }

  ScrollTrackState get scrollTrackState =>
      ScrollTrack.of((position?.context as ScrollableState)?.context);
}

class ScrollTrack extends StatefulWidget {
  final Widget child;

  const ScrollTrack({Key key, @required this.child}) : super(key: key);

  @override
  ScrollTrackState createState() => ScrollTrackState();

  static ScrollTrackState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<ScrollTrackState>());
  }
}

class ScrollTrackState extends State<ScrollTrack> {
  List<ItemContext> _items;

  StreamController<ScrollNotification> _controller;
  Stream<ScrollNotification> broadCaseStream;
  bool isFirstScrollInit = true;

  @override
  void initState() {
    super.initState();
    _items = [];
    _controller = StreamController<ScrollNotification>();
    broadCaseStream = _controller.stream.asBroadcastStream();
  }

  List<ItemContext> get items => _items;

  @override
  void didUpdateWidget(ScrollTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: widget.child,
      onNotification: (ScrollNotification notification) {
        try {
          if (!_controller.isPaused && !_controller.isClosed) {
            _controller.sink.add(notification);
          }
        } catch (err) {
          debugPrint("$TRACK_TAG${err.toString()}");
        }

        return false;
      },
    );
  }

  @override
  void dispose() {
    _items.clear();
    _items = null;
    _controller.close();
    _controller = null;
    super.dispose();
  }

  void addItem(ItemContext context) {
    if (!_items.contains(context)) {
      _items.add(context);
    }
  }

  bool removeItem(ItemContext context) {
    return _items.remove(context);
  }
}

class TrackItem extends StatefulWidget {
  final Widget child;

  final int index;

  final dynamic data;

  const TrackItem({Key key, this.child, this.index, this.data})
      : super(key: key);

  @override
  _TrackItemState createState() => _TrackItemState();
}

class _TrackItemState extends State<TrackItem> {
  ScrollTrackState _parent;

  ItemContext _currentContext;

  StreamSubscription<ScrollNotification> streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      streamSubscription = _parent?.broadCaseStream?.listen(_onScroll);
      _onEvent();
    });
  }

  void _onScroll(ScrollNotification event) {
    if (event is! ScrollEndNotification) return;
    _onEvent();
  }

  void _onEvent() {
    double vpHeight = 0.0;

    if (_currentContext == null) return;

    RenderObject renderObject = _currentContext.context.findRenderObject();

    if (renderObject == null || !renderObject.attached) return;

    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;
    ScrollableState scrollableState = Scrollable.of(_currentContext.context);
    ScrollPosition scrollPosition = scrollableState.position;
    RevealedOffset vpOffset = viewport.getOffsetToReveal(renderObject, 0.0);
    final Size size = renderObject?.semanticBounds?.size;

    double deltaTop;
    double deltaBottom;

    if (scrollPosition.axis == Axis.vertical) {
      vpHeight = viewport.paintBounds.height;
      deltaTop = vpOffset.offset - scrollPosition.pixels;
      deltaBottom = deltaTop + size.height;
    } else if (scrollPosition.axis == Axis.horizontal) {
      vpHeight = viewport.paintBounds.width;
      deltaTop = vpOffset.offset - scrollPosition.pixels;
      deltaBottom = deltaTop + size.width;
    }
    bool isInViewport = false;

    isInViewport = (deltaTop >= 0 && deltaTop < vpHeight);

    if (!isInViewport) {
      isInViewport = (deltaBottom > 0.0 && deltaBottom < vpHeight);
    }

    if (isInViewport && !_currentContext.exposure) {
      defaultScrollTrackListener(_currentContext);
    }
    _currentContext.exposure = isInViewport;
    // print("${_currentContext.index}-----> offset:${vpOffset.offset}----isIn:$isInViewport");
  }

  @override
  void didUpdateWidget(TrackItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.child != widget.child ||
        oldWidget.data != widget.data) {
      if (_currentContext != null) {
        _parent?.removeItem(_currentContext);
      }
      _currentContext = ItemContext(context, widget.index, data: widget.data);
      _parent?.addItem(_currentContext);
    }
  }

  @override
  void dispose() {
    _parent?.removeItem(_currentContext);
    _currentContext = null;
    streamSubscription?.cancel();
    streamSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_parent == null) {
      _parent = ScrollTrack.of(context);
    }
    if (_parent == null) {
      return widget.child;
    }
    if (_currentContext == null) {
      _currentContext = ItemContext(context, widget.index, data: widget.data);
      _parent.addItem(_currentContext);
    }
    return widget.child;
  }
}

class ItemContext {
  final BuildContext context;
  final int index;
  final dynamic data;
  bool exposure = false;

  ItemContext(this.context, this.index, {this.data});
}
