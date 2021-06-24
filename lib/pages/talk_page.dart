import 'package:flutter/material.dart';
import 'package:flutter_boss_says/pages/follow_page.dart';
import 'package:flutter_boss_says/pages/square_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({Key key}) : super(key: key);

  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentIndex = 0;
  List<String> mTitles = ["追踪", "广场"];
  List<Widget> mPages = [FollowPage(), SquarePage()];

  PageController mPageController = PageController();

  @override
  void dispose() {
    print('TalkPage====>dispose');
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('TalkPage====>init');
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
      mCurrentIndex = index;
      mPageController.jumpToPage(index);
      setState(() {});
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
    BaseTool.toast(msg: "clickSearch");
  }
}
