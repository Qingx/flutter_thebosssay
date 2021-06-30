import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:get/get.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BossInfoPage extends StatelessWidget {
  const BossInfoPage({Key key}) : super(key: key);

  void onBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                image: AssetImage(R.assetsImgTestSplash),
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
              bottom: 92, left: MediaQuery.of(context).size.width / 2 - 80),
          Image.asset(
            R.assetsImgBossHandRight,
            width: 24,
            height: 24,
          ).positionOn(
              bottom: 92, right: MediaQuery.of(context).size.width / 2 - 80),
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
            child: Image.asset(
              R.assetsImgTestPhoto,
              width: 64,
              height: 64,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "莉莉娅",
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
                  "灵魂莲华",
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
    String text =
        "物万号资往约算事打见飞增边着必影已叫受导音须接空边单压场选济共因办标广压严机无界律运活质带日的场群第如易。又制目林他派人拉采北计前县成标把较群义极持革安做种国新观两科消解加别格认角使件金音公样还广团斯况等广计关观料多产效数认质数时想信白力划七时元平号子性小组立民。声么性必听我外类战处型去速复只长构于力作电构体响每导象并放好员空好结更得组切影会快划众导。选回西月统反领型革百是再点道除细阶调其着般调下正展设工五光流容想题大过那变品并政值手过办水设半住。构使确你从约展导各员保济拉整该较京都工带历温断列写品斯离积近花别领提见比验非整调件素清毛团高身第。工五光流容想题大过那变品并政值手过办水设半住。构使确你从约展导各员保济拉整该较京都工带历温断列写品斯离积近花别领提见比验非整调件素清毛团高身第。";
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
      margin: EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: BaseColor.textGray),
        softWrap: true,
      ),
    );
  }
}
