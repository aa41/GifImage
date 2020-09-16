//import 'dart:async';
//import 'dart:collection';
//import 'dart:io';
//import 'dart:typed_data';
//
//import 'package:flutter/foundation.dart';
//import 'package:flutter/rendering.dart';
//import 'package:flutter/widgets.dart';
//import 'dart:ui' as ui show Codec, hashValues;
//
//class GifImage extends StatefulWidget {
//  const GifImage({
//    Key key,
//    @required this.image,
//    this.width,
//    this.height,
//    this.color,
//    this.colorBlendMode,
//    this.fit,
//    this.alignment = Alignment.center,
//    this.repeat = ImageRepeat.noRepeat,
//    this.centerSlice,
//    this.matchTextDirection = false,
//    this.gaplessPlayback = false,
//    this.filterQuality = FilterQuality.low,
//    this.frameBuilder,
//    this.loadingBuilder,
//    this.semanticLabel,
//    this.excludeFromSemantics,
//    @required this.controller,
//  })  : assert(image != null),
//        assert(alignment != null),
//        assert(repeat != null),
//        assert(filterQuality != null),
//        assert(matchTextDirection != null),
//        super(key: key);
//
//  final GifImageProviderMixin image;
//
//  final GifAnimationController controller;
//
//  /// A builder function responsible for creating the widget that represents
//  /// this image.
//  ///
//  /// If this is null, this widget will display an image that is painted as
//  /// soon as the first image frame is available (and will appear to "pop" in
//  /// if it becomes available asynchronously). Callers might use this builder to
//  /// add effects to the image (such as fading the image in when it becomes
//  /// available) or to display a placeholder widget while the image is loading.
//  ///
//  /// To have finer-grained control over the way that an image's loading
//  /// progress is communicated to the user, see [loadingBuilder].
//  ///
//  /// ## Chaining with [loadingBuilder]
//  ///
//  /// If a [loadingBuilder] has _also_ been specified for an image, the two
//  /// builders will be chained together: the _result_ of this builder will
//  /// be passed as the `child` argument to the [loadingBuilder]. For example,
//  /// consider the following builders used in conjunction:
//  ///
//  /// {@template flutter.widgets.image.chainedBuildersExample}
//  /// ```dart
//  /// Image(
//  ///   ...
//  ///   frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
//  ///     return Padding(
//  ///       padding: EdgeInsets.all(8.0),
//  ///       child: child,
//  ///     );
//  ///   },
//  ///   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
//  ///     return Center(child: child);
//  ///   },
//  /// )
//  /// ```
//  ///
//  /// In this example, the widget hierarchy will contain the following:
//  ///
//  /// ```dart
//  /// Center(
//  ///   Padding(
//  ///     padding: EdgeInsets.all(8.0),
//  ///     child: <image>,
//  ///   ),
//  /// )
//  /// ```
//  /// {@endtemplate}
//  ///
//  /// {@tool snippet --template=stateless_widget_material}
//  ///
//  /// The following sample demonstrates how to use this builder to implement an
//  /// image that fades in once it's been loaded.
//  ///
//  /// This sample contains a limited subset of the functionality that the
//  /// [FadeInImage] widget provides out of the box.
//  ///
//  /// ```dart
//  /// @override
//  /// Widget build(BuildContext context) {
//  ///   return DecoratedBox(
//  ///     decoration: BoxDecoration(
//  ///       color: Colors.white,
//  ///       border: Border.all(),
//  ///       borderRadius: BorderRadius.circular(20),
//  ///     ),
//  ///     child: Image.network(
//  ///       'https://example.com/image.jpg',
//  ///       frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
//  ///         if (wasSynchronouslyLoaded) {
//  ///           return child;
//  ///         }
//  ///         return AnimatedOpacity(
//  ///           child: child,
//  ///           opacity: frame == null ? 0 : 1,
//  ///           duration: const Duration(seconds: 1),
//  ///           curve: Curves.easeOut,
//  ///         );
//  ///       },
//  ///     ),
//  ///   );
//  /// }
//  /// ```
//  /// {@end-tool}
//  ///
//  /// Run against a real-world image, the previous example renders the following
//  /// image.
//  ///
//  /// {@animation 400 400 https://flutter.github.io/assets-for-api-docs/assets/widgets/frame_builder_image.mp4}
//  final ImageFrameBuilder frameBuilder;
//
//  /// A builder that specifies the widget to display to the user while an image
//  /// is still loading.
//  ///
//  /// If this is null, and the image is loaded incrementally (e.g. over a
//  /// network), the user will receive no indication of the progress as the
//  /// bytes of the image are loaded.
//  ///
//  /// For more information on how to interpret the arguments that are passed to
//  /// this builder, see the documentation on [ImageLoadingBuilder].
//  ///
//  /// ## Performance implications
//  ///
//  /// If a [loadingBuilder] is specified for an image, the [Image] widget is
//  /// likely to be rebuilt on every
//  /// [rendering pipeline frame](rendering/RendererBinding/drawFrame.html) until
//  /// the image has loaded. This is useful for cases such as displaying a loading
//  /// progress indicator, but for simpler cases such as displaying a placeholder
//  /// widget that doesn't depend on the loading progress (e.g. static "loading"
//  /// text), [frameBuilder] will likely work and not incur as much cost.
//  ///
//  /// ## Chaining with [frameBuilder]
//  ///
//  /// If a [frameBuilder] has _also_ been specified for an image, the two
//  /// builders will be chained together: the `child` argument to this
//  /// builder will contain the _result_ of the [frameBuilder]. For example,
//  /// consider the following builders used in conjunction:
//  ///
//  /// {@macro flutter.widgets.image.chainedBuildersExample}
//  ///
//  /// {@tool snippet --template=stateless_widget_material}
//  ///
//  /// The following sample uses [loadingBuilder] to show a
//  /// [CircularProgressIndicator] while an image loads over the network.
//  ///
//  /// ```dart
//  /// Widget build(BuildContext context) {
//  ///   return DecoratedBox(
//  ///     decoration: BoxDecoration(
//  ///       color: Colors.white,
//  ///       border: Border.all(),
//  ///       borderRadius: BorderRadius.circular(20),
//  ///     ),
//  ///     child: Image.network(
//  ///       'https://example.com/image.jpg',
//  ///       loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
//  ///         if (loadingProgress == null)
//  ///           return child;
//  ///         return Center(
//  ///           child: CircularProgressIndicator(
//  ///             value: loadingProgress.expectedTotalBytes != null
//  ///                 ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
//  ///                 : null,
//  ///           ),
//  ///         );
//  ///       },
//  ///     ),
//  ///   );
//  /// }
//  /// ```
//  /// {@end-tool}
//  ///
//  /// Run against a real-world image, the previous example renders the following
//  /// loading progress indicator while the image loads before rendering the
//  /// completed image.
//  ///
//  /// {@animation 400 400 https://flutter.github.io/assets-for-api-docs/assets/widgets/loading_progress_image.mp4}
//  final ImageLoadingBuilder loadingBuilder;
//
//  /// If non-null, require the image to have this width.
//  ///
//  /// If null, the image will pick a size that best preserves its intrinsic
//  /// aspect ratio.
//  ///
//  /// It is strongly recommended that either both the [width] and the [height]
//  /// be specified, or that the widget be placed in a context that sets tight
//  /// layout constraints, so that the image does not change size as it loads.
//  /// Consider using [fit] to adapt the image's rendering to fit the given width
//  /// and height if the exact image dimensions are not known in advance.
//  final double width;
//
//  /// If non-null, require the image to have this height.
//  ///
//  /// If null, the image will pick a size that best preserves its intrinsic
//  /// aspect ratio.
//  ///
//  /// It is strongly recommended that either both the [width] and the [height]
//  /// be specified, or that the widget be placed in a context that sets tight
//  /// layout constraints, so that the image does not change size as it loads.
//  /// Consider using [fit] to adapt the image's rendering to fit the given width
//  /// and height if the exact image dimensions are not known in advance.
//  final double height;
//
//  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
//  final Color color;
//
//  /// Used to set the [FilterQuality] of the image.
//  ///
//  /// Use the [FilterQuality.low] quality setting to scale the image with
//  /// bilinear interpolation, or the [FilterQuality.none] which corresponds
//  /// to nearest-neighbor.
//  final FilterQuality filterQuality;
//
//  /// Used to combine [color] with this image.
//  ///
//  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
//  /// the source and this image is the destination.
//  ///
//  /// See also:
//  ///
//  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
//  final BlendMode colorBlendMode;
//
//  /// How to inscribe the image into the space allocated during layout.
//  ///
//  /// The default varies based on the other fields. See the discussion at
//  /// [paintImage].
//  final BoxFit fit;
//
//  /// How to align the image within its bounds.
//  ///
//  /// The alignment aligns the given position in the image to the given position
//  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
//  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
//  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
//  /// image with the bottom right corner of its layout bounds. Similarly, an
//  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
//  /// middle of the bottom edge of its layout bounds.
//  ///
//  /// To display a subpart of an image, consider using a [CustomPainter] and
//  /// [Canvas.drawImageRect].
//  ///
//  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
//  /// [AlignmentDirectional]), then an ambient [Directionality] widget
//  /// must be in scope.
//  ///
//  /// Defaults to [Alignment.center].
//  ///
//  /// See also:
//  ///
//  ///  * [Alignment], a class with convenient constants typically used to
//  ///    specify an [AlignmentGeometry].
//  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
//  ///    relative to text direction.
//  final AlignmentGeometry alignment;
//
//  /// How to paint any portions of the layout bounds not covered by the image.
//  final ImageRepeat repeat;
//
//  /// The center slice for a nine-patch image.
//  ///
//  /// The region of the image inside the center slice will be stretched both
//  /// horizontally and vertically to fit the image into its destination. The
//  /// region of the image above and below the center slice will be stretched
//  /// only horizontally and the region of the image to the left and right of
//  /// the center slice will be stretched only vertically.
//  final Rect centerSlice;
//
//  /// Whether to paint the image in the direction of the [TextDirection].
//  ///
//  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
//  /// drawn with its origin in the top left (the "normal" painting direction for
//  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
//  /// a scaling factor of -1 in the horizontal direction so that the origin is
//  /// in the top right.
//  ///
//  /// This is occasionally used with images in right-to-left environments, for
//  /// images that were designed for left-to-right locales. Be careful, when
//  /// using this, to not flip images with integral shadows, text, or other
//  /// effects that will look incorrect when flipped.
//  ///
//  /// If this is true, there must be an ambient [Directionality] widget in
//  /// scope.
//  final bool matchTextDirection;
//
//  /// Whether to continue showing the old image (true), or briefly show nothing
//  /// (false), when the image provider changes.
//  final bool gaplessPlayback;
//
//  /// A Semantic description of the image.
//  ///
//  /// Used to provide a description of the image to TalkBack on Android, and
//  /// VoiceOver on iOS.
//  final String semanticLabel;
//
//  /// Whether to exclude this image from semantics.
//  ///
//  /// Useful for images which do not contribute meaningful information to an
//  /// application.
//  final bool excludeFromSemantics;
//
//  @override
//  _GifImageState createState() => _GifImageState();
//}
//
//class _GifImageState extends State<GifImage> with WidgetsBindingObserver {
//  ImageStream _imageStream;
//  ImageInfo _imageInfo;
//  ImageChunkEvent _loadingProgress;
//  bool _isListeningToStream = false;
//  bool _invertColors;
//  int _frameNumber;
//  bool _wasSynchronouslyLoaded;
//  List<ImageInfo> _imageInfos =[];
//
//  GifAnimationController _controller;
//
//  int playIndex = -1;
//
//  @override
//  void initState() {
//    super.initState();
//    WidgetsBinding.instance.addObserver(this);
//    _initController();
//  }
//
//  void _initController() {
//    _controller = widget.controller;
//    _controller.addListener(_listener);
//  }
//
//  @override
//  void dispose() {
//    assert(_imageStream != null);
//    _controller?.removeListener(_listener);
//    WidgetsBinding.instance.removeObserver(this);
//    _stopListeningToStream();
//    super.dispose();
//  }
//
//  @override
//  void didChangeDependencies() {
//    _updateInvertColors();
//    _resolveImage();
//
//    if (TickerMode.of(context))
//      _listenToStream();
//    else
//      _stopListeningToStream();
//
//    super.didChangeDependencies();
//  }
//
//  @override
//  void didUpdateWidget(GifImage oldWidget) {
//    super.didUpdateWidget(oldWidget);
//    if (_isListeningToStream &&
//        (widget.loadingBuilder == null) != (oldWidget.loadingBuilder == null)) {
//      _imageStream.removeListener(_getListener(oldWidget.loadingBuilder));
//      _imageStream.addListener(_getListener());
//    }
//    if (widget.image != oldWidget.image) _resolveImage();
//    if(oldWidget.controller != widget.controller){
//      oldWidget.controller.removeListener(_listener);
//      _initController();
//    }
//  }
//
//  @override
//  void didChangeAccessibilityFeatures() {
//    super.didChangeAccessibilityFeatures();
//    setState(() {
//      _updateInvertColors();
//    });
//  }
//
//  @override
//  void reassemble() {
//    _resolveImage(); // in case the image cache was flushed
//    super.reassemble();
//  }
//
//  void _updateInvertColors() {
//    _invertColors = MediaQuery.of(context, nullOk: true)?.invertColors ??
//        SemanticsBinding.instance.accessibilityFeatures.invertColors;
//  }
//
//  void _resolveImage() {
//    final ImageStream newStream =
//        widget.image.resolve(createLocalImageConfiguration(
//      context,
//      size: widget.width != null && widget.height != null
//          ? Size(widget.width, widget.height)
//          : null,
//    ));
//    assert(newStream != null);
//    _updateSourceStream(newStream);
//  }
//
//  ImageStreamListener _getListener([ImageLoadingBuilder loadingBuilder]) {
//    loadingBuilder ??= widget.loadingBuilder;
//    return ImageStreamListener(
//      _handleImageFrame,
//      onChunk: loadingBuilder == null ? null : _handleImageChunk,
//    );
//  }
//
//  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
//    setState(() {
//      _imageInfo = imageInfo;
//      if (_imageInfos.length < widget.image.frameCount && !_imageInfos.contains(_imageInfos)) {
//        _imageInfos.add(_imageInfo);
//      }
//      _loadingProgress = null;
//      _frameNumber = _frameNumber == null ? 0 : _frameNumber + 1;
//      _wasSynchronouslyLoaded |= synchronousCall;
//    });
//  }
//
//  void _handleImageChunk(ImageChunkEvent event) {
//    assert(widget.loadingBuilder != null);
//    setState(() {
//      _loadingProgress = event;
//    });
//  }
//
//  // Updates _imageStream to newStream, and moves the stream listener
//  // registration from the old stream to the new stream (if a listener was
//  // registered).
//  void _updateSourceStream(ImageStream newStream) {
//    if (_imageStream?.key == newStream?.key) return;
//
//    if (_isListeningToStream) _imageStream.removeListener(_getListener());
//
//    if (!widget.gaplessPlayback)
//      setState(() {
//        _imageInfo = null;
//      });
//
//    setState(() {
//      _loadingProgress = null;
//      _frameNumber = null;
//      _wasSynchronouslyLoaded = false;
//    });
//
//    _imageStream = newStream;
//    if (_isListeningToStream) _imageStream.addListener(_getListener());
//  }
//
//  void _listenToStream() {
//    if (_isListeningToStream) return;
//    _imageStream.addListener(_getListener());
//    _isListeningToStream = true;
//  }
//
//  void _stopListeningToStream() {
//    if (!_isListeningToStream) return;
//    _imageStream.removeListener(_getListener());
//    _isListeningToStream = false;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    Widget result ;
//    if(playIndex <0 || playIndex>widget.image.frameCount){
//      result = Container();
//    }else{
//      result = RawImage(
//        image: _imageInfos[playIndex]?.image,
//        width: widget.width,
//        height: widget.height,
//        scale:  _imageInfos[playIndex]?.scale ?? 1.0,
//        color: widget.color,
//        colorBlendMode: widget.colorBlendMode,
//        fit: widget.fit,
//        alignment: widget.alignment,
//        repeat: widget.repeat,
//        centerSlice: widget.centerSlice,
//        matchTextDirection: widget.matchTextDirection,
//        invertColors: _invertColors,
//        filterQuality: widget.filterQuality,
//      );
//    }
//
//
//    if (!widget.excludeFromSemantics) {
//      result = Semantics(
//        container: widget.semanticLabel != null,
//        image: true,
//        label: widget.semanticLabel ?? '',
//        child: result,
//      );
//    }
//
//    if (widget.frameBuilder != null)
//      result = widget.frameBuilder(
//          context, result, _frameNumber, _wasSynchronouslyLoaded);
//
//    if (widget.loadingBuilder != null)
//      result = widget.loadingBuilder(context, result, _loadingProgress);
//
//    return result;
//  }
//
//  @override
//  void debugFillProperties(DiagnosticPropertiesBuilder description) {
//    super.debugFillProperties(description);
//    description.add(DiagnosticsProperty<ImageStream>('stream', _imageStream));
//    description.add(DiagnosticsProperty<ImageInfo>('pixels', _imageInfo));
//    description.add(DiagnosticsProperty<ImageChunkEvent>(
//        'loadingProgress', _loadingProgress));
//    description.add(DiagnosticsProperty<int>('frameNumber', _frameNumber));
//    description.add(DiagnosticsProperty<bool>(
//        'wasSynchronouslyLoaded', _wasSynchronouslyLoaded));
//  }
//
//  void _listener() {
//    playIndex = (_controller.value * widget.image.frameCount).floor();
//    List<OnGifPlayingListener> _listeners = _controller.gifPlayingCallbacks;
//    for (OnGifPlayingListener callback in _listeners) {
//      callback(_controller.currPlayCount, playIndex);
//    }
//  }
//}
//
//mixin GifImageProviderMixin<T> on ImageProvider<T> {
//  int frameCount = -1;
//  int repetitionCount = -1;
//}
//
//class GifAssetImageProvider extends AssetImage
//    with GifImageProviderMixin<AssetBundleImageKey> {
//  GifAssetImageProvider(String assetName) : super(assetName);
//
//  @override
//  ImageStreamCompleter load(AssetBundleImageKey key) {
//    return MultiFrameImageStreamCompleter(
//      codec: _loadAsync(key),
//      scale: key.scale,
//      informationCollector: () sync* {
//        yield DiagnosticsProperty<ImageProvider>('GIFImage provider', this);
//        yield DiagnosticsProperty<AssetBundleImageKey>('GIFImage key', key);
//      },
//    );
//  }
//
//  /// Fetches the image from the asset bundle, decodes it, and returns a
//  /// corresponding [ImageInfo] object.
//  ///
//  /// This function is used by [load].
//  @protected
//  Future<ui.Codec> _loadAsync(AssetBundleImageKey key) async {
//    final ByteData data = await key.bundle.load(key.name);
//    if (data == null) throw 'Unable to read data';
//    var codec = await PaintingBinding.instance
//        .instantiateImageCodec(data.buffer.asUint8List());
//    frameCount = codec.frameCount;
//    repetitionCount = codec.repetitionCount;
//    return codec;
//  }
//}
//
//class GifImageNetWorkImageProvider extends ImageProvider<NetworkImage>
//    with GifImageProviderMixin<NetworkImage>
//    implements NetworkImage {
//  /// Creates an object that fetches the image at the given URL.
//  ///
//  /// The arguments [url] and [scale] must not be null.
//  GifImageNetWorkImageProvider(this.url, {this.scale = 1.0, this.headers})
//      : assert(url != null),
//        assert(scale != null);
//
//  @override
//  final String url;
//
//  @override
//  final double scale;
//
//  @override
//  final Map<String, String> headers;
//
//  @override
//  Future<NetworkImage> obtainKey(ImageConfiguration configuration) {
//    return SynchronousFuture<NetworkImage>(this);
//  }
//
//  @override
//  ImageStreamCompleter load(NetworkImage key) {
//    // Ownership of this controller is handed off to [_loadAsync]; it is that
//    // method's responsibility to close the controller's stream when the image
//    // has been loaded or an error is thrown.
//    final StreamController<ImageChunkEvent> chunkEvents =
//        StreamController<ImageChunkEvent>();
//
//    return MultiFrameImageStreamCompleter(
//      codec: _loadAsync(key, chunkEvents),
//      chunkEvents: chunkEvents.stream,
//      scale: key.scale,
//      informationCollector: () {
//        return <DiagnosticsNode>[
//          DiagnosticsProperty<ImageProvider>('Image provider', this),
//          DiagnosticsProperty<NetworkImage>('Image key', key),
//        ];
//      },
//    );
//  }
//
//  // Do not access this field directly; use [_httpClient] instead.
//  // We set `autoUncompress` to false to ensure that we can trust the value of
//  // the `Content-Length` HTTP header. We automatically uncompress the content
//  // in our call to [consolidateHttpClientResponseBytes].
//  static final HttpClient _sharedHttpClient = HttpClient()
//    ..autoUncompress = false;
//
//  static HttpClient get _httpClient {
//    HttpClient client = _sharedHttpClient;
//    assert(() {
//      if (debugNetworkImageHttpClientProvider != null)
//        client = debugNetworkImageHttpClientProvider();
//      return true;
//    }());
//    return client;
//  }
//
//  Future<ui.Codec> _loadAsync(
//    NetworkImage key,
//    StreamController<ImageChunkEvent> chunkEvents,
//  ) async {
//    try {
//      assert(key == this);
//
//      final Uri resolved = Uri.base.resolve(key.url);
//      final HttpClientRequest request = await _httpClient.getUrl(resolved);
//      headers?.forEach((String name, String value) {
//        request.headers.add(name, value);
//      });
//      final HttpClientResponse response = await request.close();
//      if (response.statusCode != HttpStatus.ok)
//        throw Exception(
//            'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');
//
//      final Uint8List bytes = await consolidateHttpClientResponseBytes(
//        response,
//        onBytesReceived: (int cumulative, int total) {
//          chunkEvents.add(ImageChunkEvent(
//            cumulativeBytesLoaded: cumulative,
//            expectedTotalBytes: total,
//          ));
//        },
//      );
//      if (bytes.lengthInBytes == 0)
//        throw Exception('NetworkImage is an empty file: $resolved');
//
//      var codec = await PaintingBinding.instance.instantiateImageCodec(bytes);
//      frameCount = codec.frameCount;
//      repetitionCount = codec.repetitionCount;
//      return codec;
//    } finally {
//      chunkEvents.close();
//    }
//  }
//
//  @override
//  bool operator ==(dynamic other) {
//    if (other.runtimeType != runtimeType) return false;
//    final NetworkImage typedOther = other;
//    return url == typedOther.url && scale == typedOther.scale;
//  }
//
//  @override
//  int get hashCode => ui.hashValues(url, scale);
//
//  @override
//  String toString() => '$runtimeType("$url", scale: $scale)';
//}
//
//class GifAnimationController extends AnimationController {
//  /// The value at which this animation is deemed to be dismissed.
//  final double lowerBound;
//
//  /// The value at which this animation is deemed to be completed.
//  final double upperBound;
//
//  /// A label that is used in the [toString] output. Intended to aid with
//  /// identifying animation controller instances in debug output.
//  final String debugLabel;
//
//  /// The behavior of the controller when [AccessibilityFeatures.disableAnimations]
//  /// is true.
//  ///
//  /// Defaults to [AnimationBehavior.normal] for the [new AnimationController]
//  /// constructor, and [AnimationBehavior.preserve] for the
//  /// [new AnimationController.unbounded] constructor.
//  final AnimationBehavior animationBehavior;
//
//  GifAnimationController(this.playCount,
//      {this.lowerBound,
//      this.upperBound,
//      this.debugLabel,
//      this.animationBehavior,
//      @required TickerProvider vsync})
//      : super(
//            lowerBound: lowerBound,
//            upperBound: upperBound,
//            debugLabel: debugLabel,
//            animationBehavior: animationBehavior,
//            vsync: vsync) {
//    _direction = _AnimationDirection.forward;
//    addStatusListener(_statusListener);
//  }
//
//  /// Returns an [Animation<double>] for this animation controller, so that a
//  /// pointer to this object can be passed around without allowing users of that
//  /// pointer to mutate the [AnimationController] state.
//  Animation<double> get view => this;
//
//  /// The length of time this animation should last.
//  ///
//  /// If [reverseDuration] is specified, then [duration] is only used when going
//  /// [forward]. Otherwise, it specifies the duration going in both directions.
//  Duration duration;
//
//  /// The length of time this animation should last when going in [reverse].
//  ///
//  /// The value of [duration] us used if [reverseDuration] is not specified or
//  /// set to null.
//  Duration reverseDuration;
//
//  final int playCount;
//
//  int playFrameIndex;
//
//  int currPlayCount = 0;
//
//  _AnimationDirection _direction;
//
//  List<OnGifPlayingListener> gifPlayingCallbacks = [];
//
//  void addGifPlayingCallback(OnGifPlayingListener gifPlayingListener) {
//    gifPlayingCallbacks.add(gifPlayingListener);
//  }
//
//  void removeGifPlayingCallback(OnGifPlayingListener gifPlayingListener) {
//    gifPlayingCallbacks.remove(gifPlayingListener);
//  }
//
//  @override
//  void dispose() {
//    removeStatusListener(_statusListener);
//    super.dispose();
//  }
//
//  @override
//  void reset() {
//    currPlayCount = 0;
//    super.reset();
//  }
//
//  @override
//  TickerFuture forward({double from}) {
//    _direction = _AnimationDirection.forward;
//    return super.forward(from: from);
//  }
//
//  @override
//  TickerFuture reverse({double from}) {
//    _direction = _AnimationDirection.reverse;
//    return super.reverse(from: from);
//  }
//
//  void _statusListener(AnimationStatus status) {
//    switch (status) {
//      case AnimationStatus.dismissed:
//        break;
//      case AnimationStatus.forward:
//        break;
//      case AnimationStatus.reverse:
//        break;
//      case AnimationStatus.completed:
//        currPlayCount++;
//        if (currPlayCount >= playCount) {
//          currPlayCount = 0;
//          return;
//        }
//        if (currPlayCount < playCount) {
//          if (_direction == _AnimationDirection.reverse) {
//            reverse(from: lowerBound);
//          } else {
//            forward(from: lowerBound);
//          }
//        }
//        break;
//    }
//  }
//}
//
//typedef Function OnGifPlayingListener(int playCount, int playFrameIndex);
//
//enum _AnimationDirection {
//  /// The animation is running from beginning to end.
//  forward,
//
//  /// The animation is running backwards, from end to beginning.
//  reverse,
//}
