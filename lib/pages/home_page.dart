import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/scheme_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/version_update_dialog.dart';
import 'package:flutter_boss_says/event/jpush_article_event.dart';
import 'package:flutter_boss_says/event/jump_boss_event.dart';
import 'package:flutter_boss_says/pages/home_boss_page.dart';
import 'package:flutter_boss_says/pages/home_mine_page.dart';
import 'package:flutter_boss_says/pages/home_speech_page.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:get/get.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int mCurrentIndex;
  List<String> mTitles;
  List<List<String>> mIcons;
  List<Widget> mPages;

  PageController mPageController;
  StreamSubscription<BaseEvent> eventDispose;

  @override
  void dispose() {
    super.dispose();

    doPageEnd();

    mPageController?.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    mCurrentIndex = 0;
    mTitles = ["言论", "老板", "我的"];
    mIcons = [
      [R.assetsImgTalkNormal, R.assetsImgTalkSelect],
      [R.assetsImgBossNormal, R.assetsImgBossSelect],
      [R.assetsImgMineNormal, R.assetsImgMineSelect]
    ];
    mPages = [HomeSpeechPage(), HomeBossPage(), HomeMinePage()];

    mPageController = PageController();

    eventBus();

    onJPushCallback();

    doDeviceID();

    doPageStart();

    SchemeApi.ins().doAppScheme();

    FlutterAppBadger.removeBadge();

    checkUpdate();
  }

  void doPageStart() {
    TalkingApi.ins().obtainPageStart("HomePage");
  }

  void doPageEnd() {
    TalkingApi.ins().obtainPageStart("HomePage");
  }

  void doDeviceID() async {
    TalkingApi.ins().obtainDeviceId().listen((event) {
      print('TalkingData:deviceId：$event');
    });
  }

  void checkUpdate() {
    UserApi.ins().obtainCheckUpdate().listen((event) {
      showVersionUpdate(context, onDismiss: () {
        Get.back();
      }, onConfirm: () {
        SchemeApi.ins().jumpAppStore();
        Get.back();
      });
    });
  }

  ///eventBus
  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == JumpBossEvent) {
        jumpToBoss();
      }
    });
  }

  void jumpToBoss() {
    mPageController.animateToPage(1,
        duration: Duration(milliseconds: 240), curve: Curves.easeInOutExpo);
  }

  void onJPushCallback() {
    ///极光推送回调
    JpushApi.ins().jPush.addEventHandler(
      onReceiveMessage: (msg) async {
        //消息回调
        print('message:$msg');
        Global.hint.setHint(msg["content"]);

        FlutterAppBadger.removeBadge();
      },
      onReceiveNotification: (msg) async {
        //通知回调
        print('notification:$msg');

        if (msg["extras"]["articleId"] != null) {
          String bossId = msg["extras"]["bossId"];
          String updateTime = msg["extras"]["updateTime"];
          print('notification:$bossId');
          print('notification:$updateTime');

          Global.eventBus.fire(JpushArticleEvent(
              bossId: bossId, updateTime: int.parse(updateTime)));

          FlutterAppBadger.removeBadge();
        }
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        //点击通知
        print("onOpenNotification:$message");

        if (message["extras"]["articleId"] != null) {
          Get.to(() => WebArticlePage(),
              arguments: message["extras"]["articleId"]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("loginStatus ===>> ${UserConfig.getIns().loginStatus}");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: pageWidget(),
      bottomNavigationBar: bottomWidget(),
    );
  }

  Widget pageWidget() {
    return PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (int) {
          mCurrentIndex = int;
          setState(() {});
        },
        controller: mPageController,
        itemCount: mPages.length,
        itemBuilder: (context, index) {
          return mPages[index];
        });
  }

  Widget bottomWidget() {
    return Container(
      color: Colors.white,
      alignment: Alignment.topCenter,
      height: 50 + MediaQuery.of(context).padding.bottom,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: bottomItemWidget(0)),
          Expanded(child: bottomItemWidget(1)),
          Expanded(child: bottomItemWidget(2)),
        ],
      ),
    );
  }

  Widget bottomItemWidget(int index) {
    Color mCurrentColor =
        mCurrentIndex == index ? BaseColor.accent : BaseColor.textGray;
    String mCurrentIcon = mIcons[index][mCurrentIndex == index ? 1 : 0];

    return Container(
      height: 50,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          itemLabelWidget(index),
          itemIconWidget(mCurrentIcon),
          Text(
            mTitles[index],
            style: TextStyle(fontSize: 12, color: mCurrentColor),
            textAlign: TextAlign.center,
          )
        ],
      ),
    ).onClick(() {
      if (Global.hint.canUse.value) {
        mCurrentIndex = index;
        mPageController.jumpToPage(mCurrentIndex);
        setState(() {});
      } else {
        BaseTool.toast(msg: "应用出错了");
      }
    });
  }

  Widget itemLabelWidget(int index) {
    return Container(
      width: 36,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
        color: mCurrentIndex == index ? BaseColor.accent : Colors.white,
      ),
    );
  }

  Widget itemIconWidget(String icon) {
    return Image.asset(
      icon,
      width: 24,
      height: 24,
    );
  }
}
