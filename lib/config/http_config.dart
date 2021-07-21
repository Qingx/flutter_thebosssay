class HttpConfig {
  static const Get = "get";
  static const Post = "post";
  static const EmptySign = "EMPTY_SIGN";
  static const EmptyToken = "EMPTY_TOKEN";

  static final globalEnv = DevEnv();

  static String fullUrl(String url) {
    if (url == null || url.isEmpty) {
      return "";
    }

    if (url.startsWith(r'http')) {
      return url;
    } else if (url.startsWith(r'/')) {
      return "${globalEnv.downUrl}$url";
    } else {
      return "${globalEnv.downUrl}/$url";
    }
  }
}

abstract class IEnv {
  /// 判断是否为开发模式
  bool get isDebug;

  /// 网络接口
  String get baseUrl;

  /// 文件上传
  String get fileUrl;

  /// 文件下载
  String get downUrl;
}

class DevEnv extends IEnv {
  @override
  bool get isDebug => true;

  @override
  String get baseUrl {
    // return "http://192.168.1.106:8087/"; //李
    // return "http://192.168.1.115:8086/"; //熊
    return "http://tianjiemedia.com/"; //阿里云
  }

  @override
  String get fileUrl => "http://file-tr.hii-m.net";

  @override
  String get downUrl => "http://download-tr.hii-m.net";
}

class UatEnv extends IEnv {
  @override
  bool get isDebug => false;

  @override
  String get baseUrl => "http://124.70.72.199:8765/";

  @override
  String get fileUrl => "http://192.144.169.58:9999/";

  @override
  String get downUrl => "http://192.144.169.58:8888/";
}
