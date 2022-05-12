
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class DailyPosterPage extends StatelessWidget {
  List<String> icons = [
    R.assetsImgShareWechatColor,
    R.assetsImgShareTimelineColor,
    R.assetsImgShareSaveImgColor
  ];
  List<String> names = ["微信", "朋友圈", "保存到本地"];

  GlobalKey cutKey = GlobalKey();

  DailyEntity entity;

  DailyPosterPage(this.entity, {Key key}) : super(key: key);

  void doClick(int index) {
    switch (index) {
      case 0:
        BaseTool.shareImgToSession(cutKey);
        break;
      case 1:
        BaseTool.shareImgToTimeline(cutKey);
        break;
      case 2:
        BaseTool.saveCutImage(cutKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfffbfbfb),
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            Container(
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(
                    child: Container(
                      height: 32,
                      margin: EdgeInsets.only(right: 68, left: 40),
                      alignment: Alignment.center,
                      child: Text(
                        "生成海报",
                        style: TextStyle(
                          color: BaseColor.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: bodyWidget(context)),
            Container(
              height: 112,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(child: shareItem(0)),
                  Expanded(child: shareItem(1)),
                  Expanded(child: shareItem(2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget(context) {
    double matchParent = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 54),
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 295 / 542,
        child: RepaintBoundary(
          key: cutKey,
          child: Container(
            color: Color(0x29d8d8d8),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                        width: matchParent,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(R.assetsImgDailyBgDark),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: matchParent,
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    R.assetsImgDailyMarksLight,
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.cover,
                                  ).marginOn(top: 32, left: 16),
                                  Expanded(
                                    child: Text(
                                      entity.content,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        height: 1.8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      softWrap: true,
                                      textAlign: TextAlign.start,
                                      maxLines: 7,
                                      overflow: TextOverflow.ellipsis,
                                    ).marginOn(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                      bottom: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ).positionOn(
                              top: 120,
                              bottom: 40,
                              right: 12,
                              left: 12,
                            ),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              child: Image.network(
                                HttpConfig.fullUrl(entity.bossHead),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ).positionOn(right: 28, top: 72),
                            Container(
                              width: matchParent,
                              height: 48,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    entity.bossName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    entity.bossRole,
                                    style: TextStyle(
                                      color: Color(0xff7a7a7a),
                                      fontSize: 10,
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ).positionOn(left: 12, right: 98, top: 72),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 6,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            color: Colors.white),
                        child: Text(
                          "Boss语录",
                          style:
                              TextStyle(color: Color(0xffb3b3b3), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 64,
                  padding: EdgeInsets.only(left: 32),
                  child: Row(
                    children: [
                      Image.asset(
                        R.assetsImgShareQrCode,
                        width: 36,
                        height: 36,
                      ).marginOn(right: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "下载Boss说APP 获取更多Boss语录",
                              style: TextStyle(
                                color: Color(0xff7a7a7a),
                                fontSize: 9.4,
                              ),
                              softWrap: false,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(bottom: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 3.1,
                                  height: 3.1,
                                  margin: EdgeInsets.only(right: 3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: BaseColor.accent,
                                  ),
                                ),
                                Text(
                                  "生平故事",
                                  style: TextStyle(
                                    color: Color(0xff7a7a7a),
                                    fontSize: 7,
                                  ),
                                ),
                                Container(
                                  width: 3.1,
                                  height: 3.1,
                                  margin: EdgeInsets.only(right: 3, left: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: BaseColor.accent,
                                  ),
                                ),
                                Text(
                                  "创业经历",
                                  style: TextStyle(
                                    color: Color(0xff7a7a7a),
                                    fontSize: 7,
                                  ),
                                ),
                                Container(
                                  width: 3.1,
                                  height: 3.1,
                                  margin: EdgeInsets.only(right: 3, left: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: BaseColor.accent,
                                  ),
                                ),
                                Text(
                                  "职场感悟",
                                  style: TextStyle(
                                    color: Color(0xff7a7a7a),
                                    fontSize: 7,
                                  ),
                                ),
                                Container(
                                  width: 3.1,
                                  height: 3.1,
                                  margin: EdgeInsets.only(right: 3, left: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: BaseColor.accent,
                                  ),
                                ),
                                Text(
                                  "公司管理",
                                  style: TextStyle(
                                    color: Color(0xff7a7a7a),
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget shareItem(int index) {
    return Container(
      height: 112,
      padding: EdgeInsets.only(bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icons[index],
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
          Text(
            names[index],
            style: TextStyle(color: Color(0xff979797), fontSize: 10),
            softWrap: false,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).onClick(() {
      doClick(index);
    });
  }
}
