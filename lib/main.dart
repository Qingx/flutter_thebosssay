import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/pages/splash_page.dart';
import 'package:flutter_boss_says/util/base_sp.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:get/get.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  registerJiGuang();

  registerWeChat();
}

///注册微信
void registerWeChat() {
  fluwx
      .registerWxApi(
          appId: "wx5fd9da0bd24efe83",
          universalLink: "https://file.tianjiemedia.com/",
          doOnIOS: true,
          doOnAndroid: false)
      .then((value) {
    print("registerWechat:$value");
  });
}

///注册极光推送
void registerJiGuang() {
  JpushApi.ins().jPush.setup(
      appKey: "f98cfa8459c6510944ebbefd",
      channel: "developer-default",
      production: false,
      debug: false);

  ///极光申请推送权限
  JpushApi.ins().jPush.applyPushAuthority();

  ///极光推送注册成功回调id
  JpushApi.ins().jPush.getRegistrationID().then((value) {
    print('registerJPush:$value');
  });

  ///极光推送通知权限回调
  JpushApi.ins().jPush.isNotificationEnabled().then((value) {
    print("isJPushOpen:$value");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseSP.init();
    Get.lazyPut(() => Global.user, tag: "user");
    Get.lazyPut(() => Global.hint, tag: "hint");

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(backgroundColor: Colors.white),
      home: SplashPage(),
    );
  }
}
