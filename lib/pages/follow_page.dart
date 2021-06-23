import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:rxdart/rxdart.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({Key key}) : super(key: key);

  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage>
    with AutomaticKeepAliveClientMixin, BasePageController {
  int mCurrentTab = 0;
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = true;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

  @override
  void initState() {
    super.initState();

    builderFuture = getData();
    // concat([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], false);

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    // List<int> testData = [];
    List<int> testData=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    Observable.just(testData).delay(Duration(seconds: 2)).listen((event) {
      hasData = true;
      concat(event, loadMore);
      setState(() {});
    }, onDone: () {
      if (loadMore) {
        controller.finishLoad();
      } else {
        controller.resetLoadState();
        controller.finishRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      print('data:${snapshot.data}');
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return Container(color: Colors.red);
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidgetPage(
          slivers: [topWidget(), bodyWidget()],
          controller: controller,
          scrollController: scrollController,
          hasData: hasData,
          loadData: loadData),
    );
  }

  Widget topWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return tabWidget();
          } else if (index == 1) {
            return cardWidget();
          } else {
            return titleWidget();
          }
        },
        childCount: 3,
      ),
    );
  }

  Widget tabWidget() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(index);
          },
          itemCount: 16,
        ),
      ),
    );
  }

  Widget tabItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;
    Color bgColor =
        mCurrentTab == index ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = mCurrentTab == index ? Colors.white : BaseColor.accent;
    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          index % 2 == 0 ? "全部" : "职业作者",
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      setState(() {});
    });
  }

  Widget cardWidget() {
    return Container(
      height: 164,
      padding: EdgeInsets.only(top: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return cardItemWidget(index);
          },
          itemCount: 12,
        ),
      ),
    );
  }

  Widget cardItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right),
      child: Center(
        child: Text("哈利路亚"),
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      color: BaseColor.pageBg,
      height: 64,
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "最近更新",
            style: TextStyle(
                color: BaseColor.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ).marginOn(left: 16),
          Text(
            "共25篇",
            style: TextStyle(color: BaseColor.textDark, fontSize: 14),
          ).marginOn(left: 16)
        ],
      ),
    );
  }

  Widget bodyWidget() {
    return mData.isNullOrEmpty()
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return emptyWidget();
              },
              childCount: 1,
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return bodyItemWidget(index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget bodyItemWidget(int index) {
    return index < mData.length
        ? Container(
            height: 80,
            color: Colors.primaries[index % Colors.primaries.length],
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        : Container(
            height: 32,
            color: Colors.black,
          );
  }

  Widget emptyWidget() {
    String path = R.assetsImgTestPhoto;
    String content = "暂时还没有数据哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        392;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Flexible(
                child: Text(content,
                        style: TextStyle(fontSize: 18, color: BaseColor.line),
                        textAlign: TextAlign.center)
                    .marginOn(top: 16))
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
