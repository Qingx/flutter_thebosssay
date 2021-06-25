import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
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
  bool hasData = false;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

  @override
  bool get wantKeepAlive => true;

  @override
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
          physics: BouncingScrollPhysics(),
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
          index % 2 == 0 ? "混子上单" : "草食打野",
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

  Widget cardWidget() {
    return Container(
      height: 188,
      padding: EdgeInsets.only(top: 24, bottom: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
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

  Widget emptyCardWidget() {
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: 12),
      height: 188,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            R.assetsImgEmptyBoss,
            width: 100,
            height: 80,
            fit: BoxFit.cover,
          ),
          Text(
            "当前还没有追踪的老板！",
            style: TextStyle(fontSize: 14, color: Color(0x80000000)),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
          ),
          Container(
            height: 28,
            width: 120,
            decoration: BoxDecoration(
                border: Border.all(color: BaseColor.accent, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(
              child: Text(
                "立即添加",
                style: TextStyle(fontSize: 16, color: BaseColor.accent),
                textAlign: TextAlign.center,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          )
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 64,
            height: 64,
            child: Stack(
              children: [
                ClipOval(
                  child: Image.asset(
                      index % 2 == 0
                          ? R.assetsImgTestPhoto
                          : R.assetsImgTestHead,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover),
                ),
                Container(
                  height: 14,
                  padding: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ).positionOn(top: 0, right: 0)
              ],
            ),
          ),
          Text(
            index % 2 == 0 ? "莉莉娅" : "神里凌华",
            style: TextStyle(color: BaseColor.textDark, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            index % 2 == 0 ? "灵魂莲华" : "精神信仰",
            style: TextStyle(color: BaseColor.textGray, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    ).onClick(() {
      Get.to(() => BossHomePage());
    });
  }

  Widget titleWidget() {
    return Container(
      color: BaseColor.pageBg,
      height: 40,
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
        ? "搞什么副业可以月入过万"
        : "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    String head = index % 2 == 0 ? R.assetsImgTestHead : R.assetsImgTestPhoto;
    String content = index % 2 == 0
        ? "领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原…"
        : "领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志";
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.only(left: 14, right: 14),
      height: 176,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    head,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  "莉莉娅",
                  style:
                      TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 8),
                Expanded(
                  child: Text(
                    "灵魂莲华灵魂莲华灵魂莲华灵魂莲华",
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(left: 8),
                ),
              ],
            ),
          ),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
            textAlign: TextAlign.start,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "8.2k收藏·19.9w人围观",
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "2020/03/02",
                  style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget bodyItemPhotoWidget(int index) {
    String title = index % 2 == 0
        ? "搞什么副业可以月入过万"
        : "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    String head = index % 2 == 0 ? R.assetsImgTestHead : R.assetsImgTestPhoto;
    String content = index % 2 == 0
        ? "领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原…"
        : "领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.only(left: 14, right: 14),
      height: 176,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.asset(
                                head,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              "莉莉娅",
                              style: TextStyle(
                                  fontSize: 14, color: BaseColor.textDarkLight),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(left: 8),
                            Expanded(
                              child: Text(
                                "灵魂莲华灵魂莲华灵魂莲华灵魂莲华",
                                style: TextStyle(
                                    fontSize: 14, color: BaseColor.textGray),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ).marginOn(left: 8),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        content,
                        style: TextStyle(
                            fontSize: 14, color: BaseColor.textDarkLight),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    R.assetsImgTestHead,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ).marginOn(left: 16),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "8.2k收藏·19.9w人围观",
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "2020/03/02",
                  style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
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
          loadCardWidget(),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
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

  Widget loadCardWidget() {
    return Container(
      height: 188,
      padding: EdgeInsets.only(top: 24, bottom: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return loadCardItemWidget(index);
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Widget loadCardItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: BaseColor.loadBg,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right),
    );
  }

  Widget loadingItemWidget(double width, double margin) {
    return Container(
      width: (MediaQuery.of(context).size.width - 32) * width,
      height: 16,
      margin: EdgeInsets.only(left: 16, right: 16, top: margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: BaseColor.loadBg,
      ),
    );
  }
}
