import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key key}) : super(key: key);

  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage>
    with AutomaticKeepAliveClientMixin, BasePageController {
  int mCurrentTab = 0;
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = false;

  Future<bool> getData() {
    return Observable
        .just(true)
        .delay(Duration(seconds: 2))
        .last;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    scrollController?.dispose();
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
    List<int> testData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
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
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return BaseWidget.refreshWidgetPage(
        slivers: [topWidget(), bodyWidget()],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData);
  }

  Widget topWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return tabWidget();
        },
        childCount: 1,
      ),
    );
  }

  Widget tabWidget() {
    return Container(
      height: 28,
      margin: EdgeInsets.only(top: 12, bottom: 16),
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
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          index % 2 == 0 ? "全部" : "职业作者",
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      if (index != mCurrentTab) {
        mCurrentTab = index;
        builderFuture = getData();
        setState(() {});
      }
    });
  }

  Widget bodyWidget() {
    return mData.isNullOrEmpty()
        ? SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return emptyBodyWidget();
        },
        childCount: 1,
      ),
    )
        : SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return index % 2 == 0
              ? bodyItemPhotoWidget(index)
              : bodyItemWidget(index);
        },
        childCount: mData.length,
      ),
    );
  }

  Widget bodyItemWidget(int index) {
    String title = index % 2 == 0
        ? "2021年好消息！成都人可买三亚万科海景房，总价低到超乎想象！"
        : "继法国之后，德国也宣布不承认中国疫苗，接种者或将被拒绝入境接种者或将被拒绝入境";

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 18,
                      color: BaseColor.textDark,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "烽火崛起·19.9w人围观·6小时前",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 16),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              R.assetsImgTestPhoto,
              width: 96,
              height: 64,
              fit: BoxFit.cover,
            ),
          ).marginOn(left: 16),
        ],
      ),
    );
  }

  Widget bodyItemPhotoWidget(int index) {
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            height: 80,
            child: MediaQuery.removePadding(
              removeBottom: true,
              removeTop: true,
              context: context,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 4,
                  childAspectRatio:
                  (MediaQuery
                      .of(context)
                      .size
                      .width - 28 - 8) / 3 / 80,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      R.assetsImgTestHead,
                      height: 80,
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            "广告·海南万科",
            style: TextStyle(fontSize: 13, color: BaseColor.textGray),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ).marginOn(top: 16),
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = " 最近还没有更新哦～";
    double height = MediaQuery
        .of(context)
        .size
        .height -
        MediaQuery
            .of(context)
            .padding
            .top -
        180;
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
                    style:
                    TextStyle(fontSize: 18, color: BaseColor.textGray),
                    textAlign: TextAlign.center)
                    .marginOn(top: 16))
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
    });
  }

  Widget loadingWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          loadTabWidget(),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(0.2, 8),
          loadingItemWidget(0.6, 8),
          Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SpinKitFadingCircle(
                    color: Color(0xff0e1e1e1),
                    size: 48,
                    duration: Duration(milliseconds: 2000),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget loadTabWidget() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return loadTabItemWidget(index);
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Widget loadTabItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;
    return Container(
      width: 80,
      margin: EdgeInsets.only(left: left, right: right),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          color: BaseColor.loadBg),
    );
  }

  Widget loadingItemWidget(double width, double margin) {
    return Container(
      width: (MediaQuery
          .of(context)
          .size
          .width - 32) * width,
      height: 16,
      margin: EdgeInsets.only(left: 16, right: 16, top: margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: BaseColor.loadBg,
      ),
    );
  }
}
