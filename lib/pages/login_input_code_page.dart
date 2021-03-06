import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_verification_box/verification_box.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class LoginInputCodePage extends StatefulWidget {
  const LoginInputCodePage({Key key}) : super(key: key);

  @override
  _LoginInputCodePageState createState() => _LoginInputCodePageState();
}

class _LoginInputCodePageState extends State<LoginInputCodePage> {
  int count = 60;
  String countText = "60s";
  String codeNumber = "";
  StreamSubscription<int> mDispose;
  String phoneNumber;
  String rnd = "";

  void onBack() {
    Get.back();
  }

  void onSubmitted(content) {
    codeNumber = content;

    if (isInputAvailable(true)) {
      BaseWidget.showLoadingAlert("正在尝试登录...", context);

      UserApi.ins()
          .obtainSignPhone(phoneNumber, codeNumber, rnd)
          .flatMap((event) {
            UserConfig.getIns().token = event.token;
            Global.user.setUser(event.userInfo);

            TalkingApi.ins().obtainLogin(event.userInfo.id);

            JpushApi.ins().addAlias(event.userInfo.id);

            if (!event.userInfo.tags.isNullOrEmpty()) {
              JpushApi.ins().addTags(event.userInfo.tags);
            }
            CacheProvider.getIns().clearBoss();
            CacheProvider.getIns().clearArticle();

            return AppApi.ins().obtainGetAllFollowBoss("-1");
          })
          .onErrorReturn([])
          .flatMap((value) {
            CacheProvider.getIns().insertBossList(value);
            return AppApi.ins().obtainGetTackArticleList(PageParam(), "-1");
          })
          .onErrorReturn(BaseEmpty.emptyArticle)
          .timeout(Duration(seconds: 8))
          .listen((event) {
            CacheProvider.getIns().insertArticle(event);
            DataConfig.getIns().fromSplash = true;

            Get.offAll(() => HomePage());
          }, onError: (res) {
            Get.back();
            print(res);
            BaseTool.toast(msg: "登录失败,${res.msg}");
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

  ///尝试发送验证码
  void trySendCode() {
    BaseWidget.showLoadingAlert("正在发送验证码...", context);
    UserApi.ins().obtainSendCode(phoneNumber, 0).listen((event) {
      Get.back();
      rnd = event;
      countDown();
      setState(() {});
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: res.msg);
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

    var data = Get.arguments as Map<String, dynamic>;
    phoneNumber = data["phoneNumber"];
    rnd = data["rnd"];

    countDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            R.assetsImgLoginLabel,
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
        trySendCode();
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
