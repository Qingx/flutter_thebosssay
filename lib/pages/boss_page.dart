import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/pages/all_boss_page.dart';
import 'package:flutter_boss_says/pages/boss_content_page.dart';
import 'package:flutter_boss_says/pages/search_boss_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class BossPage extends StatefulWidget {
  const BossPage({Key key}) : super(key: key);

  @override
  _BossPageState createState() => _BossPageState();
}

class _BossPageState extends State<BossPage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentIndex;

  PageController mPageController;
  List<BossLabelEntity> labels;
  List<BossContentPage> mPages;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    mPageController?.dispose();
  }

  @override
  void initState() {
    super.initState();

    mCurrentIndex = 0;
    mPageController = PageController();

    labels = DataConfig.getIns().bossLabels;
    mPages = labels.map((e) => BossContentPage(e.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BaseWidget.statusBar(context, true),
          titleTabBar(),
          tabWidget(),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: mPageController,
                  itemCount: mPages.length,
                  itemBuilder: (context, index) {
                    return mPages[index];
                  },
                  onPageChanged: (index) {
                    mCurrentIndex = index;
                    setState(() {});
                  },
                ).positionOn(top: 0, bottom: 0, left: 0, right: 0),
                floatWidget().positionOn(right: 16, bottom: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget titleTabBar() {
    return Container(
      alignment: Alignment.bottomLeft,
      color: BaseColor.pageBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          titleWidget().marginOn(left: 16),
          Expanded(child: SizedBox()),
          Image.asset(
            R.assetsImgSearch,
            width: 20,
            height: 20,
          ).onClick(onSearchClick).marginOn(right: 16)
        ],
      ),
    );
  }

  Widget titleWidget() {
    return Text(
      "老板's",
      style: TextStyle(
        fontSize: 28,
        color: BaseColor.textDark,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget tabWidget() {
    return Container(
      height: 52,
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(labels[index], index);
          },
          itemCount: labels.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    bool hasSelect = labels[mCurrentIndex].id == entity.id;

    Color bgColor = hasSelect ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = hasSelect ? Colors.white : BaseColor.accent;

    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          entity.name,
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      if (index != mCurrentIndex) {
        mCurrentIndex = index;
        mPageController.jumpToPage(mCurrentIndex);
      }
    });
  }

  Widget floatWidget() {
    return Container(
      alignment: Alignment.center,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BaseColor.accent,
        boxShadow: [
          BoxShadow(
              color: BaseColor.accentShadow,
              offset: Offset(0.0, 4.0), //阴影x,y轴偏移量
              blurRadius: 4, //阴影模糊程度
              spreadRadius: 0 //阴影扩散程度
              )
        ],
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
    ).onClick(() {
      Get.to(() => AllBossPage(), transition: Transition.downToUp);
    });
  }

  void onSearchClick() {
    Get.to(() => SearchBossPage(), transition: Transition.fadeIn);
  }
}
