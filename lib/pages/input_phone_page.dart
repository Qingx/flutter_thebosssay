import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';

class InputPhone extends StatelessWidget {
  const InputPhone({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("hello world").onClick(() {
          Get.back();
        }),
      ),
    );
  }
}
