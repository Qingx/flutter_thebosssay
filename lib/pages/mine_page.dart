import 'package:flutter/material.dart';
import 'package:flutter_boss_says/pages/input_phone_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';

class MinePage extends StatelessWidget {
  const MinePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: BaseColor.pageBg,
      child: Container(
        alignment: Alignment.center,
        height: 48,
        margin: EdgeInsets.only(left: 64, right: 64),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: BaseColor.accent,
        ),
        child: Text(
          "登录",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          softWrap: false,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ).onClick(() {
        Get.to(() => InputPhonePage());
      }),
    );
  }
}
