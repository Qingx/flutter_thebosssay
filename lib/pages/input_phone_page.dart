import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/pages/input_code_page.dart';
import 'package:flutter_boss_says/pages/service_privacy_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class InputPhonePage extends StatefulWidget {
  const InputPhonePage({Key key}) : super(key: key);

  @override
  _InputPhonePageState createState() => _InputPhonePageState();
}

class _InputPhonePageState extends State<InputPhonePage> {
  String phoneNumber = "";
  bool hasChecked = false;
  TapGestureRecognizer serviceTap;
  TapGestureRecognizer privacyTap;

  @override
  void dispose() {
    super.dispose();

    serviceTap?.dispose();
    privacyTap?.dispose();
  }

  @override
  void initState() {
    super.initState();

    serviceTap = TapGestureRecognizer();
    privacyTap = TapGestureRecognizer();

    weChatCallback();
  }

  ///尝试微信登录
  void tryWechatLogin(String code) {
    if (hasChecked) {
      BaseWidget.showLoadingAlert("正在尝试登录...", context);

      UserApi.ins().obtainWechatLogin(code).listen((event) {
        UserConfig.getIns().token = event.token;
        Global.user.setUser(event.userInfo);

        ///极光推送设置别名
        Global.jPush.setAlias(event.userInfo.id).then((value) {
          print("jPush.setAlias:$value");
        });

        TalkingApi.ins().obtainLogin(event.userInfo.id);

        BaseTool.toast(msg: "登录成功");
        Get.offAll(() => HomePage());
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: "登录失败,${res.msg}");
      });
    } else {
      BaseTool.toast(msg: "请阅读并同意《服务条款》和《隐私政策》");
    }
  }

  ///微信登录回调
  void weChatCallback() {
    fluwx.weChatResponseEventHandler.distinct((a, b) => a == b).listen((resp) {
      if (mounted) {}
      if (resp is fluwx.WeChatAuthResponse) {
        print('wxAuthCode:${resp.code}');
        tryWechatLogin(resp.code);
      }
    });
  }

  ///尝试跳转微信授权
  Future<void> tryJumpWechat() async {
    if (hasChecked) {
      BaseTool.isWeChatInstalled().then((result) {
        if (result) {
          fluwx
              .sendWeChatAuth(
                  scope: "snsapi_userinfo", state: "flutter_boss_says")
              .then((value) {
            print("jumpToWx:$value");
          }).catchError((error) {
            print('jumpToWx:$error');
          });
        } else {
          print('jumpToWx:未安装微信应用');
          BaseTool.toast(msg: "请先下载并安装微信");
        }
      });
    } else {
      BaseTool.toast(msg: "请阅读并同意《服务条款》和《隐私政策》");
    }
  }

  void onBack() {
    Get.back();
  }

  void onChanged(content) {
    phoneNumber = content;
    setState(() {});
  }

  void showService() {
    Get.to(() => ServicePrivacyPage(), arguments: "0");
  }

  void showPrivacy() {
    Get.to(() => ServicePrivacyPage(), arguments: "1");
  }

  void trySendCode() {
    if (isInputAvailable(true)) {
      BaseWidget.showLoadingAlert("正在发送验证码...", context);

      UserApi.ins().obtainSendCode(phoneNumber, 0).listen((event) {
        var data = {"phoneNumber": phoneNumber, "rnd": event};
        Get.off(() => InputCodePage(), arguments: data);
      }, onError: (res) {
        Get.back();
        print(res);
        BaseTool.toast(msg: "验证码发送失败，${res.msg}");
      });
    }
  }

  ///判断输入是否可用
  bool isInputAvailable(bool needToast) {
    if (phoneNumber.isEmpty) {
      if (needToast) {
        BaseTool.toast(msg: "请输入你的手机号");
      }
      return false;
    }
    if (phoneNumber[0] != "1") {
      if (needToast) {
        BaseTool.toast(msg: "请输入正确的手机号");
      }
      return false;
    }

    if (phoneNumber.length != 11) {
      if (needToast) {
        BaseTool.toast(msg: "请输入正确的手机号");
      }
      return false;
    }

    if (needToast && !hasChecked) {
      BaseTool.toast(msg: "请阅读并同意《服务条款》和《隐私政策》");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topBar(),
            topWidget(),
            Container(
              margin: EdgeInsets.only(left: 16, top: 48),
              padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
              decoration: BoxDecoration(
                  color: BaseColor.loadBg,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Text(
                "+86",
                style: TextStyle(fontSize: 12, color: BaseColor.textDark),
                softWrap: false,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            inputWidget(),
            Container(
              height: 40,
              margin: EdgeInsets.only(left: 8, top: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  checkBoxWidget(),
                  RichText(
                    text: TextSpan(
                      text: "我已阅读并同意",
                      style: TextStyle(color: BaseColor.textGray, fontSize: 12),
                      children: [
                        TextSpan(
                            text: "《服务条款》",
                            style: TextStyle(
                                color: BaseColor.accent, fontSize: 12),
                            recognizer: serviceTap..onTap = showService),
                        TextSpan(
                          text: "和",
                          style:
                              TextStyle(color: BaseColor.accent, fontSize: 12),
                        ),
                        TextSpan(
                            text: "《隐私政策》",
                            style: TextStyle(
                                color: BaseColor.accent, fontSize: 12),
                            recognizer: privacyTap..onTap = showPrivacy),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  confirmWidget(),
                ],
              ),
            ),
            DataConfig.getIns().isShangjia ? weChatWidget() : SizedBox(),
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
                    "请输入您的手机号，首次登录将自动注册",
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
            R.assetsImgLoginLabel,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ).marginOn(right: 32),
        ],
      ),
    );
  }

  Widget inputWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(left: 16, right: 16, top: 24),
      child: TextField(
        onChanged: onChanged,
        cursorColor: BaseColor.accent,
        maxLines: 1,
        autofocus: false,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "请输入手机号",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BaseColor.accent)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BaseColor.line)),
        ),
      ),
    );
  }

  Widget checkBoxWidget() {
    return Container(
      padding: EdgeInsets.all(8),
      child: hasChecked
          ? Icon(Icons.check_circle_rounded, size: 16, color: BaseColor.accent)
          : Icon(Icons.radio_button_unchecked,
              size: 16, color: BaseColor.loadBg),
    ).onClick(() {
      hasChecked = !hasChecked;
      setState(() {});
    });
  }

  Widget confirmWidget() {
    Color color = isInputAvailable(false) && hasChecked
        ? BaseColor.accent
        : BaseColor.loadBg;
    return Container(
      height: 48,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 48, left: 16, right: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)), color: color),
      child: Text(
        "发送验证码",
        style: TextStyle(
            fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    ).onClick(trySendCode);
  }

  Widget weChatWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 64),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            R.assetsImgWeChatLogo,
            width: 32,
            height: 32,
          ),
          Text(
            "微信授权登录",
            style: TextStyle(fontSize: 14, color: BaseColor.textDark),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.start,
          ).marginOn(left: 8),
        ],
      ),
    ).onClick(() {
      tryJumpWechat();
    });
  }
}
