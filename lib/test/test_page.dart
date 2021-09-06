import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
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
  ScrollController scrollController;
  TabController tabController;
  bool isFinish = true;

  @override
  void initState() {
    super.initState();

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
    scrollController = ScrollController();
    tabController = TabController(length: 3, vsync: this);

    scrollController.addListener(() {
      double min = scrollController.position.minScrollExtent;
      double max = scrollController.position.maxScrollExtent;
      double current = scrollController.position.pixels;
      print('min=>$min');
      print('max=>$max');
      print('current=>$current');
      print('----------------------');
    });
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

  Widget listWidget() {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            height: 40,
            color: Colors.primaries[index % Colors.primaries.length],
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            child: Text(index.toString()),
          );
        },
        itemCount: 80,
      ),
    );
  }

  void loadData(bool loadMore) {
    var list = ["a", "b", "c", "d", "e", "f", "g"];

    if (isFinish) {
      isFinish = false;
      Observable.just(list).delay(Duration(milliseconds: 500)).listen((event) {
        if (loadMore) {
          data.addAll(event);
        } else {
          data = event;
        }
        setState(() {
          isFinish = true;
        });
      });
    }
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
                forceElevated: innerBoxIsScrolled,
                toolbarHeight: 40,
                backgroundColor: Colors.white,
                leading: Container(
                  child: GestureDetector(
                    child:
                        Icon(Icons.arrow_back, size: 26, color: Colors.white),
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
                floating: false,
                pinned: true,
                snap: false,
                expandedHeight:
                    MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
                flexibleSpace: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: Container(
                    height:
                        MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
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
                    child: ListView(
                      children: [
                        bossInfoWidget(),
                        bossInfoBottomWidget(),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.blue,
                      controller: tabController,
                      tabs: [
                        Tab(
                          text: "111",
                        ),
                        Tab(
                          text: "222",
                        ),
                        Tab(
                          text: "333",
                        ),
                      ],
                    ),
                  ),
                )),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            Container(
              child: listWidget(),
            ),
            Container(
              child: listWidget(),
            ),
            Container(
              child: listWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
