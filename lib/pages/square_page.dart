import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
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
    return Observable.just(true).delay(Duration(seconds: 2)).last;
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
      return BaseWidget.loadingWidget();
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
                  child: Image.asset(R.assetsImgTestHead),
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
    String path = R.assetsImgTestPhoto;
    String content = "暂时还没有数据哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
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
      loadData(false);
    });
  }
}
