import 'package:build/build.dart';
import 'package:gif_image/router/mxc_router.dart';
import 'package:source_gen/source_gen.dart';

Builder mxcRouter(BuilderOptions options) => LibraryBuilder(MxcRouterGen(),generatedExtension: '.internal.dart');


Builder mxcWriteRouter(BuilderOptions options) =>LibraryBuilder(MXCWriteRouterGen(),generatedExtension: '.internal_invalid.dart');