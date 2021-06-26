import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/dialog/boss_setting_dialog.dart';
import 'package:flutter_boss_says/pages/boss_info_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';

class BossHomePage extends StatelessWidget {
  const BossHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Stack(
          children: [
            BodyWidget(),
            topBar(context),
          ],
        ),
      ),
    );
  }

  void onBack() {
    Get.back();
  }

  void onShare() {
    Share.share('https://cn.bing.com', subject: "必应");
  }

  void onSetting(BuildContext context) {
    showBossSettingDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      BaseTool.toast(msg: "开启推送");
      Get.back();
    });
  }

  Widget topBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back, size: 26, color: Colors.white)
              .marginOn(left: 16)
              .onClick(onBack),
          Expanded(child: SizedBox()),
          Image.asset(R.assetsImgShareWhite, width: 24, height: 24)
              .marginOn(right: 12)
              .onClick(onShare),
          Image.asset(R.assetsImgSettingWhite, width: 24, height: 24)
              .marginOn(right: 16)
              .onClick(() {
            onSetting(context);
          }),
        ],
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({Key key}) : super(key: key);

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> with BasePageController {
  var builderFuture;
  bool hasData = true;

  ScrollController scrollController;
  EasyRefreshController controller;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

  @override
  void dispose() {
    super.dispose();
    scrollController?.dispose();
    controller?.dispose();
  }

  @override
  void initState() {
    super.initState();

    // concat([0, 1, 2, 3, 4, 5, 6], false);
    builderFuture = getData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    Observable.just([0, 1, 2, 3, 4]).delay(Duration(seconds: 2)).listen(
        (event) {
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

  void onFollow(bool status) {
    if (!status) {
      BaseTool.toast(msg: "追踪");
    }
  }

  void onWatchMore() {
    Get.to(() => BossInfoPage());
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      print('data:${snapshot.data}');
      if (snapshot.hasData) {
        return Column(
          children: [
            topWidget(),
            numberWidget(),
            Expanded(child: contentWidget()),
          ],
        );
      } else
        return Container(color: Colors.red);
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget topWidget() {
    return Container(
      height: MediaQuery.of(context).padding.top + 40 + 160,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(R.assetsImgTestPhoto),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bossInfoWidget(),
          bossInfoBottomWidget(),
        ],
      ),
    );
  }

  Widget bossInfoWidget() {
    return Container(
      height: 64,
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              R.assetsImgTestHead,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "神里凌华",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          softWrap: false,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        height: 20,
                        padding: EdgeInsets.only(left: 8, right: 8),
                        margin: EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: Color(0x80000000),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "精神信仰",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "19.9万阅读·185篇言论",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).marginOn(left: 16),
          ),
        ],
      ),
    );
  }

  Widget bossInfoBottomWidget() {
    bool hasFollow = false;
    Color followColor = hasFollow ? Color(0x80efefef) : Colors.red;

    return Container(
      margin: EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: followColor,
            ),
            child: Text(
              hasFollow ? "已追踪" : "追踪",
              style: TextStyle(color: Colors.white, fontSize: 14),
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ).onClick(() {
            onFollow(hasFollow);
          }),
          Expanded(
            child: Text(
              "个人简介：府人都少物白类活从第有见易西世济社外断入府人都少物白类活从第有见易西世济社外断入府人都少物白类活从第有府人都少物白类活从第有见易西世济社外断入府人都少物白类活从第有见易西世济社外断入府人都少物白类活从第有",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
              softWrap: true,
              maxLines: 3,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ).marginOn(left: 16).onClick(() {
              onWatchMore();
            }),
          )
        ],
      ),
    );
  }

  Widget numberWidget() {
    return Container(
      height: 56,
      padding: EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "ta的言论",
            style: TextStyle(
                fontSize: 24,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "共25篇",
            style: TextStyle(fontSize: 14, color: BaseColor.textDark),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ).marginOn(left: 12),
        ],
      ),
    );
  }

  Widget contentWidget() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: BaseWidget.refreshWidgetPage(
        slivers: [bodyWidget()],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData,
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
                return MediaQuery.removePadding(
                  removeTop: true,
                  removeBottom: true,
                  context: context,
                  child: StaggeredGridView.countBuilder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    itemCount: mData.length,
                    itemBuilder: itemBuilder,
                    staggeredTileBuilder: tileBuilder,
                  ),
                );
              },
              childCount: 1,
            ),
          );
  }

  Widget itemBuilder(context, index) {
    return index <= 1
        ? bodyItemWidget(index)
        : index == 2
            ? adWidget()
            : index % 2 == 0
                ? bodyItemWidget(index)
                : bodyItemLargeWidget(index);
  }

  StaggeredTile tileBuilder(index) {
    return index <= 1
        ? StaggeredTile.fit(2)
        : index == 2
            ? StaggeredTile.fit(4)
            : StaggeredTile.fit(2);
  }

  Widget adWidget() {
    return Container(
      height: 160,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(R.assetsImgTestPhoto),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget bodyItemWidget(index) {
    bool hasLike = index % 2 == 0;
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    return Container(
      height: 216,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.white),
      child: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  height: 128,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage(R.assetsImgTestHead),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(4),
                        topEnd: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              color: BaseColor.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: BaseColor.accent,
                          ),
                          Text(
                            "19.9w",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ).marginOn(left: 8),
                          Expanded(child: SizedBox()),
                          Icon(
                            hasLike ? Icons.star : Icons.star_border_outlined,
                            size: 16,
                            color: hasLike ? Colors.orange : BaseColor.textGray,
                          ).marginOn(right: 8),
                          Text(
                            "1230",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ).marginOn(bottom: 8, left: 8, right: 8)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "2020/5/30",
            style: TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).positionOn(top: 12, left: 0, right: 0),
        ],
      ),
    );
  }

  Widget bodyItemLargeWidget(index) {
    bool hasLike = index % 2 == 0;
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    return Container(
      height: 304,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.white),
      child: Stack(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 224,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage(R.assetsImgTestSplash),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(4),
                        topEnd: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              color: BaseColor.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: BaseColor.accent,
                          ),
                          Text(
                            "19.9w",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ).marginOn(left: 8),
                          Expanded(child: SizedBox()),
                          Icon(
                            hasLike ? Icons.star : Icons.star_border_outlined,
                            size: 16,
                            color: hasLike ? Colors.orange : BaseColor.textGray,
                          ).marginOn(right: 8),
                          Text(
                            "1230",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ).marginOn(bottom: 8, left: 8, right: 8)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "2020/5/30",
            style: TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).positionOn(top: 12, left: 0, right: 0),
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        256;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Text(content,
                    style: TextStyle(fontSize: 18, color: BaseColor.textGray),
                    textAlign: TextAlign.center)
                .marginOn(top: 16),
          ],
        ),
      ),
    ).onClick(() {
      print('controller.callRefresh()');
      controller.callRefresh();
    });
  }
}