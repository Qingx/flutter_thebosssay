import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/pages/start_splash_page.dart';
import 'package:flutter_boss_says/util/base_sp.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:get/get.dart';

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

///注册极光
void registerJiGuang() {
  ///-------极光推送-------
  JpushApi.ins().registerJpush();

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

  ///-------极光认证-------
  ///初始化sdk监听
  JpushApi.ins().jverify.addSDKSetupCallBackListener((event) {
    print('registerJverifySdk:${event.toMap()}');
  });

  ///打开调试模式
  JpushApi.ins().jverify.setDebugMode(true);

  ///注册极光认证
  JpushApi.ins().registerJverify();

  ///极光认证注册回调
  JpushApi.ins().registerJverifyCallback();

  ///授权页面点击事件监听
  JpushApi.ins().addAuthClickCallback();
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
      home: StartSplashPage(),
    );
  }
}
