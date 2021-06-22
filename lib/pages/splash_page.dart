import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int currentTime = 3;
  StreamSubscription<int> mDispose;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "${currentTime}s",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    countTime();
  }

  @override
  void dispose() {
    super.dispose();

    mDispose?.cancel();
  }

  ///倒计时
  void countTime() {
    if (mDispose != null) {
      mDispose.cancel();
    }

    mDispose = Observable.periodic(Duration(seconds: 1), (i) => i)
        .take(4)
        .listen((event) {
      print(countTime);
      currentTime--;
      if (currentTime < 0) {
        Get.off(() => HomePage());
        mDispose?.cancel();
      } else {
        setState(() {});
      }
    });
  }
}
