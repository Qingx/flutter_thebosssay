import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/pages/boss_page.dart';
import 'package:flutter_boss_says/pages/mine_page.dart';
import 'package:flutter_boss_says/pages/talk_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int mCurrentIndex = 0;
  List<String> mTitles = ["言论", "老板", "我的"];
  List<List<String>> mIcons = [
    [R.assetsImgTalkNormal, R.assetsImgTalkSelect],
    [R.assetsImgBossNormal, R.assetsImgBossSelect],
    [R.assetsImgMineNormal, R.assetsImgMineSelect]
  ];
  List<Widget> mPages = [TalkPage(), BossPage(), MinePage()];

  PageController mPageController = PageController();

  @override
  Widget build(BuildContext context) {
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
      mPageController.jumpToPage(index);
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
