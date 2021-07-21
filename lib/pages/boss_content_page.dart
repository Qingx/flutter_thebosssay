import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class BossContentPage extends StatefulWidget {
  String label;

  BossContentPage(this.label, {Key key}) : super(key: key);

  @override
  _BossContentPageState createState() => _BossContentPageState();
}

class _BossContentPageState extends State<BossContentPage>
    with AutomaticKeepAliveClientMixin {
  StreamSubscription<BaseEvent> eventDispose;

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

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  ///eventBus
  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == RefreshFollowEvent) {
        ///添加追踪boss后刷新
        controller.callRefresh();
      }
    });
  }

  ///初始化获取数据
  Future<List<BossInfoEntity>> loadInitData() {
    return BossApi.ins()
        .obtainFollowBossList(widget.label, false)
        .doOnData((event) {
      mData = event;
    }).doOnError((res) {
      print(res.msg);
    }).last;
  }

  ///刷新数据
  void loadData() {
    BossApi.ins().obtainFollowBossList(widget.label, false).listen((event) {
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
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidget(
          slivers: [bodyWidget()],
          controller: controller,
          scrollController: scrollController,
          loadData: loadData),
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
              HttpConfig.fullUrl(entity.head),
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
                        BaseTool.getUpdateTime(entity.updateTime),
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
    ).onClick(() {
      Get.to(() => BossHomePage(), arguments: entity);
    });
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
