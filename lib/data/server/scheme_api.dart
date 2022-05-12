import 'package:flutter/services.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemeApi {
  SchemeApi._();

  static SchemeApi _mIns;

  factory SchemeApi.ins() => _mIns ??= SchemeApi._();

  String appStoreUrl =
      "https://apps.apple.com/cn/app/boss%E8%AF%B4-%E8%BF%BD%E8%B8%AA%E5%A4%A7%E4%BD%AC%E7%9A%84%E8%A8%80%E8%AE%BA%E8%B5%84%E8%AE%AF/id1577491957";

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
            Get.to(() => WebArticlePage(fromBoss: false), arguments: map["id"]);
          }
        }
      }
      return Future<dynamic>.value();
    });
  }

  void jumpAppStore() {
    launch(appStoreUrl);
  }
}
