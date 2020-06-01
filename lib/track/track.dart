import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const TRACK_TAG = "Track:";

typedef void OnScrollTrackListener(ItemContext context);

OnScrollTrackListener defaultScrollTrackListener = (ItemContext itemContext) {
  // debugPrint("$TRACK_TAG ---scroll---id: ${itemContext.id}----data:${itemContext?.data?.toString()}");
};

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
  Set<ItemContext> _items;

  StreamController<ScrollNotification> controller;
  Stream<ScrollNotification> broadCaseStream;
  bool isFirstScrollInit = true;

  bool isScrolling = true;

  @override
  void initState() {
    _items = HashSet();
    controller = StreamController<ScrollNotification>();
    broadCaseStream = controller.stream.asBroadcastStream();
    broadCaseStream.listen(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_){
      _tryFirstInit();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(ScrollTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tryFirstInit();
  }

  void _tryFirstInit() {
    if (isFirstScrollInit) {
      _onEvent();
      isFirstScrollInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: widget.child,
      onNotification: (ScrollNotification notification) {
        try {
          if (!controller.isPaused && !controller.isClosed) {
            controller.sink.add(notification);
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
    controller.close();
    controller = null;
    super.dispose();
  }

  bool addItem(ItemContext context) {
    return _items.add(context);
  }

  bool removeItem(ItemContext context) {
    return _items.remove(context);
  }

  void _onScroll(ScrollNotification event) {
    if (event is! ScrollEndNotification) return;
    _onEvent();
  }

  void _onEvent() {
    if (_items?.isEmpty ?? true) {
      return;
    }

    double vpHeight = 0.0;

    for (ItemContext itemContext in _items) {
      if (itemContext == null) continue;

      RenderObject renderObject = itemContext.context.findRenderObject();

      if (renderObject == null || !renderObject.attached) continue;

      final RenderAbstractViewport viewport =
          RenderAbstractViewport.of(renderObject);
      if (viewport == null) return;
      ScrollableState scrollableState = Scrollable.of(itemContext.context);
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
      if (isInViewport) {
        defaultScrollTrackListener(itemContext);
      }

        print("${itemContext.id}-----> offset:${vpOffset.offset}----isIn:$isInViewport");
    }
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

  @override
  void initState() {
    super.initState();
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
  final int id;
  final dynamic data;

  ItemContext(this.context, this.id, {this.data});
}
