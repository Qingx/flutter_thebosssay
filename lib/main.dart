import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/pages/splash_page.dart';
import 'package:flutter_boss_says/util/base_sp.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseSP.init();
    Get.lazyPut(() => Global.user, tag: "user");

    return GetMaterialApp(
      theme: ThemeData(backgroundColor: Colors.white),
      home: SplashPage(),
    );
  }
}
