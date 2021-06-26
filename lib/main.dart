import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boss_says/pages/splash_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());

  // if (Platform.isAndroid) {
  //   ///沉浸式状态栏
  //   SystemChrome.setSystemUIOverlayStyle(
  //       SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(backgroundColor: Colors.white),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SplashPage(),
      ),
    );
  }

  Widget bodyWidget() {
    return Platform.isAndroid
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: GetMaterialApp(
              theme: ThemeData(backgroundColor: Colors.white),
              home: Scaffold(
                resizeToAvoidBottomPadding: false,
                body: SplashPage(),
              ),
            ),
          )
        : GetMaterialApp(
            theme: ThemeData(backgroundColor: Colors.white),
            home: Scaffold(
              resizeToAvoidBottomPadding: false,
              body: SplashPage(),
            ),
          );
  }
}
