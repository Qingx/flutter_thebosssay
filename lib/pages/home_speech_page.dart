import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/pages/search_article_page.dart';
import 'package:flutter_boss_says/pages/speech_square_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/pages/speech_tack_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class HomeSpeechPage extends StatefulWidget {
  const HomeSpeechPage({Key key}) : super(key: key);

  @override
  _HomeSpeechPageState createState() => _HomeSpeechPageState();
}

class _HomeSpeechPageState extends State<HomeSpeechPage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentIndex;
  List<String> mTitles;
  List<Widget> mPages;

  PageController mPageController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    mCurrentIndex = 0;
    mTitles = ["追踪", "广场"];
    mPages = [SpeechTackPage(), SpeechSquarePage()];
    mPageController = PageController();
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
          Flexible(child: pageWidget()),
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
          titleWidget(0).marginOn(left: 16),
          titleWidget(1).marginOn(left: 28),
          Expanded(child: SizedBox()),
          Image.asset(
            R.assetsImgSearch,
            width: 20,
            height: 20,
          ).onClick(onSearchClick).marginOn(right: 16, bottom: 8)
        ],
      ),
    );
  }

  Widget titleWidget(int index) {
    double fontSize = mCurrentIndex == index ? 28 : 20;
    Color fontColor =
        mCurrentIndex == index ? BaseColor.textDark : BaseColor.textGray;
    return Text(
      mTitles[index],
      style: TextStyle(
          fontSize: fontSize, color: fontColor, fontWeight: FontWeight.bold),
      textAlign: TextAlign.start,
    ).onClick(() {
      if (Global.hint.canUse.value) {
        mCurrentIndex = index;
        mPageController.jumpToPage(index);
        setState(() {});
      }
    });
  }

  Widget pageWidget() {
    return PageView.builder(
      physics: BouncingScrollPhysics(),
      controller: mPageController,
      itemCount: mPages.length,
      itemBuilder: (context, index) {
        return mPages[index];
      },
      onPageChanged: (index) {
        mCurrentIndex = index;
        setState(() {});
      },
    );
  }

  void onSearchClick() {
    if (Global.hint.canUse.value) {
      Get.to(() => SearchArticlePage());
    }
  }
}
