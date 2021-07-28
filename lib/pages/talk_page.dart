import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/pages/follow_page.dart';
import 'package:flutter_boss_says/pages/search_article_page.dart';
import 'package:flutter_boss_says/pages/square_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({Key key}) : super(key: key);

  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage>
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
    mPages = [FollowPage(), SquarePage()];
    mPageController = PageController();

    getShangjia();
  }

  ///获取上架状态
  void getShangjia() {
    Observable.just(false).listen((event) {
      DataConfig.getIns().isShangjia = event;
    });
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
      height: 40,
      color: BaseColor.pageBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          titleWidget(0).marginOn(left: 16, bottom: 2),
          titleWidget(1).marginOn(left: 28, bottom: 2),
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
    );
  }

  void onSearchClick() {
    if (Global.hint.canUse.value) {
      Get.to(() => SearchArticlePage());
    }
  }
}
