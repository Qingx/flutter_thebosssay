import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class GuidePage extends StatelessWidget {
  GlobalKey<_BodyWidgetState> bodyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: BaseColor.pageBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topWidget(),
            Text(
              "为你挑选出追踪人数最多的老板",
              style: TextStyle(color: BaseColor.textGray, fontSize: 14),
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ).marginOn(left: 15),
            BodyWidget(key: bodyKey),
            addAllWidget(),
            removeAllWidget(),
          ],
        ),
      ),
    );
  }

  Widget addAllWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(left: 16, right: 16, top: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: BaseColor.accent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            R.assetsImgAim,
            width: 16,
            height: 16,
            fit: BoxFit.cover,
          ),
          Text(
            "一键追踪",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ).marginOn(left: 8)
        ],
      ),
    ).onClick(() {
      bodyKey.currentState.addAll();
    });
  }

  Widget removeAllWidget() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: BaseColor.loadBg,
      ),
      alignment: Alignment.center,
      child: Text(
        "全不选",
        style: TextStyle(
            color: BaseColor.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.start,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    ).onClick(() {
      bodyKey.currentState.removeAll();
    });
  }
}

class topWidget extends StatefulWidget {
  const topWidget({Key key}) : super(key: key);

  @override
  _topWidgetState createState() => _topWidgetState();
}

class _topWidgetState extends State<topWidget> {
  int currentTime = 5;
  String countText = "5s";

  StreamSubscription<int> mDispose;

  @override
  void initState() {
    super.initState();

    Global.user=Get.find<UserController>(tag: "user");
    countTime();
  }

  @override
  void dispose() {
    super.dispose();
    mDispose?.cancel();
  }

  ///倒计时
  void countTime() {
    if (mDispose != null) {
      mDispose.cancel();
    }

    mDispose = Observable.periodic(Duration(seconds: 1), (i) => i)
        .take(6)
        .listen((event) {
      currentTime--;
      countText = "${currentTime}s";
      if (currentTime < 0) {
        countText = "跳过";
        mDispose?.cancel();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double marginTop = MediaQuery.of(context).padding.top + 40;
    Color timeBg = Color(0x1a2343C2);

    return Container(
      height: 48,
      margin: EdgeInsets.only(top: marginTop),
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "追踪你感兴趣的老板",
            style: TextStyle(
                fontSize: 24,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            width: 48,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: timeBg,
            ),
            child: Center(
              child: Text(
                countText,
                style: TextStyle(color: BaseColor.accent, fontSize: 14),
                textAlign: TextAlign.center,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).onClick(() {
                if (countText == "跳过") {
                  DataConfig.getIns().firstUseApp = "false";
                  Get.off(() => HomePage());
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  BodyWidget({Key key}) : super(key: key);

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  double indicatorWidth = 0;
  ScrollController controller;
  List<int> listSelect = [];
  List<int> mData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  @override
  void initState() {
    super.initState();
    controller = ScrollController();

    controller.addListener(() {
      var current = controller.position.pixels;
      var max = controller.position.maxScrollExtent;
      var min = controller.position.minScrollExtent;
      // print('current=>$current');
      // print('max=>$max');
      // print('min=>$min');

      if (current >= min && current <= max) {
        indicatorWidth = 100 * (current / max);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  void addAll() {
    listSelect = [];
    listSelect.addAll(mData);
    setState(() {});

    DataConfig.getIns().firstUseApp = "false";
    Get.off(() => HomePage());
  }

  void removeAll() {
    listSelect = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      child: Column(
        children: [
          Container(
            height: 352,
            padding: EdgeInsets.only(top: 24, bottom: 24),
            child: MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: GridView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  childAspectRatio:
                      144 / (MediaQuery.of(context).size.width - 24) * 3,
                ),
                itemBuilder: (context, index) {
                  return itemWidget(index);
                },
                itemCount: mData.length,
              ),
            ),
          ),
          Container(
            height: 4,
            width: 100,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: BaseColor.loadBg,
            ),
            child: Container(
              height: 4,
              width: indicatorWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: BaseColor.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemWidget(index) {
    bool hasSelect = listSelect.contains(index);
    String head = hasSelect ? R.assetsImgTestPhoto : R.assetsImgTestHead;
    String name = hasSelect ? "神里凌华" : "莉莉娅";
    String info = hasSelect ? "精神信仰" : "灵魂莲华";
    Color nameColor = hasSelect ? Colors.white : BaseColor.textDark;
    Color infoColor = hasSelect ? Color(0x80ffffff) : BaseColor.textGray;
    Color bgColor = hasSelect ? BaseColor.accent : Colors.white;
    Color topBg = hasSelect ? Colors.white : Color(0x1a2343C2);
    Color iconColor = hasSelect ? BaseColor.accent : Colors.white;

    return Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: bgColor,
      ),
      child: Stack(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    head,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 16,
                      color: nameColor,
                      fontWeight: FontWeight.bold),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 4),
                Text(
                  info,
                  style: TextStyle(fontSize: 14, color: infoColor),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 4),
              ],
            ),
          ).positionOn(left: 0, right: 0, top: 0, bottom: 0),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
              ),
              color: topBg,
            ),
            child: Icon(
              Icons.check,
              size: 12,
              color: iconColor,
            ),
          ).positionOn(right: 0, top: 0)
        ],
      ),
    ).onClick(() {
      if (listSelect.contains(index)) {
        listSelect.remove(index);
      } else {
        listSelect.add(index);
      }
      setState(() {});
    });
  }
}
