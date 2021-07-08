import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({Key key}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  int currentTime = 5;
  String countText = "5s";

  StreamSubscription<int> mDispose;

  double indicatorWidth = 0;
  ScrollController controller;
  List<String> listSelect = [];

  List<BossInfoEntity> mData = [];

  var builderFuture;

  @override
  void dispose() {
    super.dispose();

    mDispose?.cancel();
    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = ScrollController();

    controller.addListener(() {
      var current = controller.position.pixels;
      var max = controller.position.maxScrollExtent;
      var min = controller.position.minScrollExtent;

      if (current >= min && current <= max) {
        indicatorWidth = 100 * (current / max);
        setState(() {});
      }
    });

    builderFuture = loadInitData();
  }

  ///初始化获取数据
  Future<BossEntity> loadInitData() {
    String tempId = DataConfig.getIns().tempId;

    return UserApi.ins().obtainTempLogin(tempId).flatMap((value) {
      Global.user = Get.find<UserController>(tag: "user");

      UserConfig.getIns().token = value.token;
      UserConfig.getIns().user = value.userInfo;
      Global.user.setUser(value.userInfo);
      return BossApi.ins().obtainGuideBoss();
    }).doOnData((event) {
      mData = event.records;
      listSelect = mData.map((e) => e.id).toList();

      countTime();
    }).doOnError((res) {
      print(res.msg);
    }).last;
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

  ///一键追踪
  void addAll() {
    if (!listSelect.isNullOrEmpty()) {
      followBoss();
    } else {
      BaseTool.toast(msg: "请至少选择一位老板");
    }
  }

  ///全不选
  void removeAll() {
    if (!mData.isNullOrEmpty()) {
      listSelect.clear();
      setState(() {});
    }
  }

  ///追踪boss
  void followBoss() {
    BaseWidget.showLoadingAlert("搜寻并追踪...", context);
    BossApi.ins().obtainGuideFollowList(listSelect).listen((event) {
      BaseTool.toast(msg: "追踪成功");
      DataConfig.getIns().firstUseApp = "false";
      Get.off(() => HomePage());
    }, onError: (res) {
      Get.back();
      print(res);
      BaseTool.toast(msg: res.msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: BaseColor.pageBg,
        child: FutureBuilder<BossEntity>(
          builder: builderWidget,
          future: builderFuture,
        ),
      ),
    );
  }

  Widget builderWidget(
      BuildContext context, AsyncSnapshot<BossEntity> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return Container(color: Colors.red);
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Column(
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
        bodyWidget(),
        addAllWidget(),
        removeAllWidget(),
      ],
    );
  }

  Widget topWidget() {
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

  Widget bodyWidget() {
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
                  return itemWidget(mData[index], index);
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

  Widget itemWidget(BossInfoEntity entity, int index) {
    bool hasSelect = listSelect.contains(entity.id);

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
                  child: Image.network(
                    HttpConfig.fullUrl(entity.head),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        index % 2 == 0
                            ? R.assetsImgTestPhoto
                            : R.assetsImgTestHead,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Text(
                  entity.name,
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
                  entity.role,
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
      if (listSelect.contains(entity.id)) {
        listSelect.remove(entity.id);
      } else {
        listSelect.add(entity.id);
      }
      setState(() {});
    });
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
    ).onClick(addAll);
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
    ).onClick(removeAll);
  }

  Widget loadingWidget() {
    return Container(
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
          Container(
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
                        return Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: BaseColor.loadBg,
                          ),
                        );
                      },
                      itemCount: 8,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
