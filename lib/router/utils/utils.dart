class Utils {
  static String getNameByUrl(String url) {
    if (url == null || url.isEmpty) return null;
    StringBuffer _buffer = StringBuffer('');
    List<String> segments;
    try {
      Uri uri = Uri.parse(url);
      segments = uri.pathSegments;
    } catch (err) {
      segments = url.split('/');
    }
    if (segments == null || segments.isEmpty) return url;
    segments.forEach((element) {
      _buffer.write(element.firstUpperCase());
    });

    return _buffer.toString();
  }
}

extension MXCString on String {
  String firstUpperCase() {
    if (this == null) return null;
    if (this.length <= 1) return this.toUpperCase();
    return this.substring(0, 1).toUpperCase() + this.substring(1);
  }
}
