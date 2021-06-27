import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_verification_box/verification_box.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class InputCodePage extends StatefulWidget {
  const InputCodePage({Key key}) : super(key: key);

  @override
  _InputCodePageState createState() => _InputCodePageState();
}

class _InputCodePageState extends State<InputCodePage> {
  int count = 30;
  String countText = "30s";
  String codeNumber = "";
  StreamSubscription<int> mDispose;

  void onBack() {
    Get.back();
  }

  void onSubmitted(content) {
    codeNumber = content;
    if (isInputAvailable(true)) {
      BaseWidget.showLoadingAlert("正在尝试登录...", context);

      Observable.just(1).delay(Duration(milliseconds: 2000)).listen((event) {
        BaseTool.toast(msg: "登录成功");
        Get.offAll(() => HomePage());
      });
    }
  }

  bool isInputAvailable(bool needToast) {
    if (codeNumber.length < 6) {
      if (needToast) {
        BaseTool.toast(msg: "请输入验证码！");
      }
      return false;
    }
    return true;
  }

  void countDown() {
    if (mDispose != null) {
      mDispose?.cancel();
    }
    mDispose = Observable.periodic(Duration(seconds: 1), (i) => i)
        .take(31)
        .listen((event) {
      count--;
      if (count < 0) {
        count = 30;
        countText = "重新发送";
        mDispose?.cancel();
      } else {
        countText = "${count}s";
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    mDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    countDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            topBar(),
            topWidget(),
            countWidget(),
            inputWidget(),
          ],
        ),
      ),
    );
  }

  Widget topBar() {
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      margin:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16),
      child: Icon(Icons.arrow_back, size: 26, color: BaseColor.textDark)
          .onClick(onBack),
    );
  }

  Widget topWidget() {
    return Container(
      height: 64,
      margin: EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 64,
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "登录",
                    style: TextStyle(
                        fontSize: 24,
                        color: BaseColor.textDark,
                        fontWeight: FontWeight.bold),
                    softWrap: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "输入6位数验证码",
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    softWrap: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Image.asset(
            R.assetsImgTestPhoto,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ).marginOn(right: 32),
        ],
      ),
    );
  }

  Widget countWidget() {
    return Container(
      margin: EdgeInsets.only(right: 16, top: 48),
      padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
          color: Color(0x1a2343C2),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Text(
        countText,
        style: TextStyle(fontSize: 12, color: BaseColor.accent),
        softWrap: false,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ).onClick(() {
      if (countText != "重新发送") {
        BaseTool.toast(msg: "操作频繁，请$count秒后再试！");
      } else {
        countDown();
      }
    });
  }

  Widget inputWidget() {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 24),
      child: VerificationBox(
        count: 6,
        showCursor: true,
        itemWidget: 45,
        cursorWidth: 2,
        cursorColor: BaseColor.accent,
        borderColor: BaseColor.line,
        borderWidth: 1,
        borderRadius: 4,
        textStyle: TextStyle(color: BaseColor.accent),
        focusBorderColor: BaseColor.accent,
        unfocus: true,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
