import 'package:flutter/material.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/pages/search_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class BossPage extends StatefulWidget {
  const BossPage({Key key}) : super(key: key);

  @override
  _BossPageState createState() => _BossPageState();
}

class _BossPageState extends State<BossPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('BossPage====>init');
  }

  @override
  void dispose() {
    print('BossPage====>dispose');
    super.dispose();
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
          Expanded(child: BodyWidget())
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
          titleWidget().marginOn(left: 16, bottom: 2),
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

  void onSearchClick() {
    BaseTool.toast(msg: "clickSearch");
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({Key key}) : super(key: key);

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget>
    with AutomaticKeepAliveClientMixin {
  int mCurrentTab = 0;
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  List<BossInfoEntity> mData = [];

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

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  ///初始化获取数据
  Future<List<BossInfoEntity>> loadInitData() {
    return BossApi.ins().obtainFollowBossList().doOnData((event) {
      mData = event;
    }).last;
  }

  void loadData() {
    BossApi.ins().obtainFollowBossList().listen((event) {
      mData = event;
      setState(() {});
    }, onDone: () {
      controller.finishRefresh();
    }, onError: (res) {
      print(res.msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BossInfoEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(
      BuildContext context, AsyncSnapshot<List<BossInfoEntity>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      print('data:${snapshot.data}');
      if (snapshot.hasData) {
        return Stack(
          children: [
            contentWidget().positionOn(top: 0, bottom: 0, left: 0, right: 0),
            floatWidget().positionOn(bottom: 16, right: 16),
          ],
        );
      } else
        return Container(color: Colors.red);
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidget(
          slivers: [topWidget(), bodyWidget()],
          controller: controller,
          scrollController: scrollController,
          loadData: loadData),
    );
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
      Get.to(() => SearchPage());
    });
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
        controller.callRefresh();
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
                return bodyItemWidget(mData[index], index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget bodyItemWidget(BossInfoEntity entity, int index) {
    String head = index % 2 == 0 ? R.assetsImgTestPhoto : R.assetsImgTestHead;

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      height: 80,
      color: BaseColor.pageBg,
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              entity.head,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  head,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                entity.name,
                                style: TextStyle(
                                    color: BaseColor.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).marginOn(left: 8),
                            ),
                            Image.asset(
                              R.assetsImgBossLabel,
                              width: 56,
                              height: 16,
                            ).marginOn(left: 8),
                          ],
                        ),
                      ),
                      Text(
                        "最近1小时更新",
                        style: TextStyle(
                            fontSize: 12, color: BaseColor.textDarkLight),
                        textAlign: TextAlign.end,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Text(
                  entity.role,
                  style:
                      TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        176;

    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              R.assetsImgEmptyBoss,
              width: 134,
              height: 108,
              fit: BoxFit.cover,
            ),
            Text(
              "当前还没有追踪的老板！\n点击“+”号添加",
              style: TextStyle(color: BaseColor.textGray, fontSize: 16),
              textAlign: TextAlign.center,
            ).marginOn(top: 24),
            Image.asset(
              R.assetsImgEmptyLine,
              width: 124,
              height: 174,
              fit: BoxFit.cover,
            ).marginOn(top: 16, left: 32),
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
      loadData();
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
