import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:get/get.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BossInfoPage extends StatelessWidget {
  BossInfoPage({Key key}) : super(key: key);

  BossInfoEntity entity = Get.arguments as BossInfoEntity;

  void onBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Stack(
          children: [
            bodyWidget(context),
            topBar(context),
          ],
        ),
      ),
    );
  }

  Widget topBar(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      margin:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16),
      child: Icon(Icons.arrow_back, size: 26, color: BaseColor.textDark)
          .onClick(onBack),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return Container(
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView(
          children: [
            topWidget(context),
            Container(
              height: 80,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16, top: 16),
              child: Text(
                "ta的生涯",
                style: TextStyle(
                  color: BaseColor.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: false,
                maxLines: 1,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            textWidget(),
          ],
        ),
      ),
    );
  }

  Widget topWidget(BuildContext context) {
    double height = 216 + MediaQuery.of(context).padding.top;
    return Container(
      height: height,
      child: Stack(
        children: [
          Container(
            height: height - 60,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: AssetImage(R.assetsImgMineTopBg),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(12),
                  bottomEnd: Radius.circular(12),
                ),
              ),
            ),
          ),
          infoWidget().positionOn(left: 16, right: 16, bottom: 0),
          Image.asset(
            R.assetsImgBossTopHead,
            width: 64,
            height: 64,
          ).positionOn(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + 40,
          ),
          Image.asset(
            R.assetsImgBossHandLeft,
            width: 24,
            height: 24,
          ).positionOn(
              bottom: 92, left: MediaQuery.of(context).size.width / 2 - 64),
          Image.asset(
            R.assetsImgBossHandRight,
            width: 24,
            height: 24,
          ).positionOn(
              bottom: 92, right: MediaQuery.of(context).size.width / 2 - 64),
        ],
      ),
    );
  }

  Widget infoWidget() {
    return Container(
      height: 112,
      padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              HttpConfig.fullUrl(entity.head),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  R.assetsImgTestPhoto,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  entity.name,
                  style: TextStyle(
                    color: BaseColor.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16),
                Text(
                  entity.role,
                  style: TextStyle(color: BaseColor.textGray, fontSize: 14),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget textWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
      margin: EdgeInsets.only(top: 8),
      child: Text(
        entity.info,
        style: TextStyle(fontSize: 14, color: BaseColor.textGray),
        softWrap: true,
      ),
    );
  }
}
