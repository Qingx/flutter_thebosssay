import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/event/jump_boss_event.dart';
import 'package:flutter_boss_says/event/refresh_user_event.dart';
import 'package:flutter_boss_says/pages/boss_page.dart';
import 'package:flutter_boss_says/pages/mine_page.dart';
import 'package:flutter_boss_says/pages/talk_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

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
    mPages = [TalkPage(), BossPage(), MinePage()];

    mPageController = PageController();

    doRefreshUser();

    eventBus();
  }

  ///eventBus
  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == JumpBossEvent) {
        jumpToBoss();
      }

      if (event.obj == RefreshUserEvent) {
        doRefreshUser();
      }
    });
  }

  void jumpToBoss() {
    mPageController.animateToPage(1,
        duration: Duration(milliseconds: 240), curve: Curves.easeInOutExpo);
  }

  ///刷新userInfo
  void doRefreshUser() {
    UserApi.ins().obtainRefreshUser().listen((event) {
      UserConfig.getIns().token = event.token;
      UserConfig.getIns().user = event.userInfo;
      Global.user.setUser(event.userInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("loginStatus ===>> ${UserConfig.getIns().loginStatus}");

    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      color: Colors.white,
      height: 84,
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
      height: 84 - MediaQuery.of(context).padding.bottom,
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
      mCurrentIndex = index;
      mPageController.jumpToPage(mCurrentIndex);
      setState(() {});
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
