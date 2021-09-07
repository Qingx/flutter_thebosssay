import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/sliver_persistent_header.dart';
import 'package:flutter_boss_says/util/tab_size_indicator.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  List<String> data = [];
  TabController tabController;
  EasyRefreshController controller;
  bool isFinish = true;
  bool hasData = true;
  String mCurrentType;
  List<String> typeList;

  @override
  void initState() {
    super.initState();
    mCurrentType = "1";
    typeList = ["言论演说", "新闻资讯", "传记其他"];
    data = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q"
    ];

    tabController = TabController(length: 3, vsync: this);
    controller = EasyRefreshController();
  }

  Widget bossInfoWidget() {
    return Container(
      height: 64,
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              R.assetsImgDefaultHead,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "清和",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  softWrap: false,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "1.2k阅读·1.2k篇言论·1.2k关注",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).marginOn(left: 16),
          ),
        ],
      ),
    );
  }

  Widget bossInfoBottomWidget() {
    Color followColor = Colors.red;

    return Container(
      height: 104,
      padding: EdgeInsets.only(top: 24, bottom: 16),
      margin: EdgeInsets.only(right: 16, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: followColor,
            ),
            child: Text(
              "追踪",
              style: TextStyle(color: Colors.white, fontSize: 13),
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 1),
                      margin: EdgeInsets.only(left: 8, right: 16),
                      decoration: BoxDecoration(
                        color: Color(0x80000000),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 240),
                        child: Text(
                          "灵魂莲华",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
                Text(
                  "个人简介：个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介个人简介",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  softWrap: true,
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16, top: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadWidget() {
    return Container(
      height: 80,
      color: Colors.black,
    );
  }

  Widget bodyWidget() {
    return BaseWidget.refreshWidgetPage(
      controller: controller,
      hasData: hasData,
      loadData: loadData,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Container(
                height: 64,
                color: Colors.primaries[index % Colors.primaries.length],
                padding: EdgeInsets.only(left: 16, right: 16),
                alignment: Alignment.centerLeft,
                child: Text(data[index]),
              );
            },
            childCount: data.length,
          ),
        )
      ],
    );
  }

  void loadData(bool loadMore) {
    var list = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
    ];

    Observable.just(list).delay(Duration(milliseconds: 500)).listen((event) {
      if (loadMore) {
        data.addAll(event);
        controller.finishLoad();
      } else {
        data = event;
        controller.finishRefresh();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              toolbarHeight: 40,
              backgroundColor: Colors.white,
              leading: Container(
                child: GestureDetector(
                  child: Icon(Icons.arrow_back, size: 26, color: Colors.white),
                  onTap: () => Get.back(),
                ),
              ),
              actions: [
                Image.asset(R.assetsImgShareWhite, width: 24, height: 24)
                    .marginOn(right: 20)
                    .onClick(() {
                  BaseTool.toast(msg: "onShare");
                }),
                Image.asset(R.assetsImgSettingWhite, width: 24, height: 24)
                    .marginOn(right: 16)
                    .onClick(() {
                  BaseTool.toast(msg: "onSetting");
                }),
              ],
              expandedHeight: 232,
              flexibleSpace: Container(
                height: MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 40 + 24,
                ),
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage(R.assetsImgBossTopBg),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(24),
                    ),
                  ),
                ),
                child: MediaQuery.removePadding(
                  removeTop: true,
                  removeBottom: true,
                  context: context,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      bossInfoWidget(),
                      bossInfoBottomWidget(),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: MySliverPersistentHeader(
                widget: TabBar(
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  indicator: TabSizeIndicator(),
                  labelColor: Colors.black,
                  controller: tabController,
                  tabs: [
                    Tab(
                      text: typeList[0],
                    ),
                    Tab(
                      text: typeList[1],
                    ),
                    Tab(
                      text: typeList[2],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            bodyWidget(),
            bodyWidget(),
            bodyWidget(),
          ],
        ),
      ),
    );
  }
}
