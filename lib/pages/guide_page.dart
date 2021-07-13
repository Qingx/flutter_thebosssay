import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
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

  @override
  void dispose() {
    super.dispose();

    mDispose?.cancel();
    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> json = {
      "data": [
        {
          "id": "1412617791843872770",
          "name": "马化腾",
          "role": "腾讯公司董事会主席兼首席执行官",
          "head":
              "https://ss1.baidu.com/-4o3dSag_xI4khGko9WTAnF6hhy/baike/w%3D268/sign=153b390d3bdbb6fd255be2203126aba6/b219ebc4b74543a9c6c7773a1c178a82b8011463.jpg"
        },
        {
          "id": "1412618648882786306",
          "name": "马云",
          "role": "阿里巴巴集团创始人",
          "head":
              "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fdingyue.ws.126.net%2Fnphh%3DuwwDE2xHWCXTJ8peWswO1TSCvMzsb9QHDULPWXpV1560092282821.jpg&refer=http%3A%2F%2Fdingyue.ws.126.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628660434&t=4d49ece7c550e68f4872340218a232bf"
        },
        {
          "id": "1412619182679273474",
          "name": "任正非",
          "role": "华为董事、CEO",
          "head":
              "https://www-file.huawei.com/-/media/corp2020/abouthuawei/executives/2020/renzhengfei-2020-detail.jpg"
        },
        {
          "id": "1412619857827999746",
          "name": "柳传志",
          "role": "联想控股、联想集团创始人",
          "head":
              "https://bkimg.cdn.bcebos.com/pic/a50f4bfbfbedab64c1495f14fc36afc379311e2e?x-bce-process=image/watermark,image_d2F0ZXIvYmFpa2UyNzI=,g_7,xp_5,yp_5/format,f_auto"
        },
        {
          "id": "1412659731360657409",
          "name": "史玉柱",
          "role": "商人、企业家",
          "head":
              "https://bkimg.cdn.bcebos.com/pic/6f061d950a7b02087bf4b2a03392e5d3572c11df6214?x-bce-process=image/watermark,image_d2F0ZXIvYmFpa2UxNTA=,g_7,xp_5,yp_5/format,f_auto"
        },
        {
          "id": "1412660078254764034",
          "name": "潘石屹",
          "role": "SOHO中国董事长",
          "head":
              "http://static.ws.126.net/stock/2013/8/14/2013081411234803374.jpg"
        },
        {
          "id": "1412660543440826370",
          "name": "许家印",
          "role": "中国恒大集团董事局主席、党委书记，管理学教授、博士生导师",
          "head":
              "https://bkimg.cdn.bcebos.com/pic/d043ad4bd11373f05b4756b0ad0f4bfbfbed04a0?x-bce-process=image/watermark,image_d2F0ZXIvYmFpa2U5Mg==,g_7,xp_5,yp_5/format,f_auto"
        },
        {
          "id": "1412661073705709569",
          "name": "比尔·盖茨",
          "role": "微软董事长、CEO和首席软件设计师",
          "head":
              "https://bkimg.cdn.bcebos.com/pic/9c16fdfaaf51f3de36318c129beef01f3b2979c0?x-bce-process=image/watermark,image_d2F0ZXIvYmFpa2UxNTA=,g_7,xp_5,yp_5/format,f_auto"
        }
      ]
    };

    mData = JsonConvert.fromJsonAsT<List<BossInfoEntity>>(json["data"]);

    listSelect = mData.map((e) => e.id).toList();

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

    countTime();
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

    Global.user = Get.find<UserController>(tag: "user");

    String tempId = BaseTool.createTempId();

    UserEntity entity;
    UserApi.ins().obtainTempLogin(tempId).flatMap((value) {
      DataConfig.getIns().setTempId = tempId;
      UserConfig.getIns().token = value.token;
      entity = value.userInfo;
      return BossApi.ins().obtainGuideFollowList(listSelect);
    }).listen((event) {
      entity.traceNum = listSelect.length;
      UserConfig.getIns().user = entity;
      Global.user.setUser(entity);

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
            bodyWidget(),
            addAllWidget(),
            removeAllWidget(),
          ],
        ),
      ),
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
