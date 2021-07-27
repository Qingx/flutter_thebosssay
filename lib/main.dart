import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/pages/splash_page.dart';
import 'package:flutter_boss_says/util/base_sp.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  registerJiGuang();

}

///注册极光推送
void registerJiGuang() {
  Global.jPush.setup(
      appKey: "f98cfa8459c6510944ebbefd",
      channel: "developer-default",
      production: false,
      debug: false);

  ///极光申请推送权限
  Global.jPush.applyPushAuthority();

  ///极光推送注册成功回调id
  Global.jPush.getRegistrationID().then((value) {
    print('registerJPush:$value');
  });

  ///极光推送通知权限回调
  Global.jPush.isNotificationEnabled().then((value) {
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
