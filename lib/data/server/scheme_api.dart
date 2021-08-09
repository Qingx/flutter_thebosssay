import 'package:flutter/services.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';

class SchemeApi {
  SchemeApi._();

  static SchemeApi _mIns;

  factory SchemeApi.ins() => _mIns ??= SchemeApi._();

  void doAppScheme() {
    const MethodChannel channel =
        const MethodChannel('app.storescore/storescore');

    channel.setMethodCallHandler((MethodCall call) {
      if (call.method == "BSAppScheme") {
        String url = call.arguments;
        print("url scheme=>$url");
        if (url.startsWith("thebosssays://thebosssays/launch")) {
          Map<String, String> map = url.getPathValue();
          print('url scheme=>$map}');
          if (map.containsKey("id")) {
            Get.to(()=>WebArticlePage(),arguments: map["id"]);
          }
        }
      }
      return Future<dynamic>.value();
    });
  }
}
