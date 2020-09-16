class Utils {
  static String getNameByUrl(String url) {
    if (url == null || url.isEmpty) return null;

    List<String> split = url.split('/');
    if (split == null || split.isEmpty) return url;


    StringBuffer _buffer = StringBuffer('');
    split.forEach((element) {
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
