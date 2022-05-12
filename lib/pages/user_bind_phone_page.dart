import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/ask_bind_dialog.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_verification_box/verification_box.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class UserBindPhonePage extends StatefulWidget {
  const UserBindPhonePage({Key key}) : super(key: key);

  @override
  _UserBindPhonePageState createState() => _UserBindPhonePageState();
}

class _UserBindPhonePageState extends State<UserBindPhonePage> {
  ///新手机号
  String inputNumber;
  String phoneNumber;
  String rnd;

  bool hasClickSend;

  int count;
  String countText;
  StreamSubscription<int> mDispose;
  FocusNode focusNode;

  @override
  void dispose() {
    super.dispose();

    mDispose?.cancel();
    focusNode?.dispose();
  }

  @override
  void initState() {
    super.initState();

    rnd = "";
    count = 60;
    countText = "60s";
    hasClickSend = false;

    focusNode = FocusNode();
  }

  ///输入的新手机号
  void onChanged(content) {
    inputNumber = content;
    setState(() {});
  }

  ///判断输入是否可用
  bool isInputAvailable(bool needToast) {
    if (inputNumber.isNullOrEmpty()) {
      if (needToast) {
        BaseTool.toast(msg: "请输入你的手机号");
      }
      return false;
    }
    if (inputNumber[0] != "1") {
      if (needToast) {
        BaseTool.toast(msg: "请输入正确的手机号");
      }
      return false;
    }

    if (inputNumber.length != 11) {
      if (needToast) {
        BaseTool.toast(msg: "请输入正确的手机号");
      }
      return false;
    }

    return true;
  }

  ///尝试点击发送
  void tryClickSend() {
    focusNode?.unfocus();
    if (isInputAvailable(true)) {
      if (!hasClickSend) {
        trySendCode();
      } else {
        if (countText != "重新发送") {
          BaseTool.toast(msg: "操作频繁，请$count秒后再试！");
        } else {
          trySendCode();
        }
      }
    }
  }

  ///尝试发送验证码
  void trySendCode() {
    focusNode?.unfocus();
    phoneNumber = inputNumber;
    BaseWidget.showLoadingAlert("正在发送验证码...", context);
    UserApi.ins().obtainSendCode(phoneNumber, 3).listen((event) {
      rnd = event;
      countDown();
      hasClickSend = true;
      setState(() {});

      Get.back();
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: res.msg);
    });
  }

  ///开启倒计时
  void countDown() {
    if (mDispose != null) {
      mDispose?.cancel();
    }
    mDispose = Observable.periodic(Duration(seconds: 1), (i) => i)
        .take(61)
        .listen((event) {
      count--;
      if (count < 0) {
        count = 60;
        countText = "重新发送";
        mDispose?.cancel();
      } else {
        countText = "${count}s";
      }
      setState(() {});
    });
  }

  ///提交code
  void onSubmitted(content) {
    showAskBindDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      Get.back();

      BaseWidget.showLoadingAlert("正在绑定...", context);
      UserApi.ins().obtainBindPhone(phoneNumber, content, rnd).listen((event) {
        UserConfig.getIns().token = event.token;
        Global.user.setUser(event.userInfo);

        Get.back();
        Get.back();

        BaseTool.toast(msg: "绑定成功");
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: "绑定失败");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: BaseColor.loadBg,
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              color: BaseColor.loadBg,
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 28),
                      alignment: Alignment.center,
                      child: Text(
                        "绑定手机号",
                        style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "请输入你的手机号",
              style: TextStyle(
                  fontSize: 18,
                  color: BaseColor.textDark,
                  fontWeight: FontWeight.bold),
              softWrap: false,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).marginOn(top: 24, left: 16, right: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: inputPhoneWidget(),
                ),
                Container(
                  height: 32,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  margin: EdgeInsets.only(left: 8, right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: isInputAvailable(false)
                        ? BaseColor.accent
                        : BaseColor.loadBg,
                  ),
                  child: Text(
                    "发送",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ).onClick(tryClickSend),
              ],
            ),
            Visibility(
              visible: hasClickSend,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "填写6位数验证码",
                    style: TextStyle(
                        fontSize: 18,
                        color: BaseColor.textDark,
                        fontWeight: FontWeight.bold),
                    softWrap: false,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(top: 32, left: 16, right: 16),
                  countWidget(),
                ],
              ),
            ),
            Visibility(
              visible: hasClickSend,
              child: inputCodeWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputPhoneWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(left: 16, right: 16, top: 24),
      child: TextField(
        onChanged: onChanged,
        cursorColor: BaseColor.accent,
        maxLines: 1,
        autofocus: false,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "输入手机号",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BaseColor.accent)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BaseColor.line)),
        ),
      ),
    );
  }

  Widget countWidget() {
    return Container(
      margin: EdgeInsets.only(right: 16, top: 32),
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
    ).onClick(tryClickSend);
  }

  Widget inputCodeWidget() {
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
