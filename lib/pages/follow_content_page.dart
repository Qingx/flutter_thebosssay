import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/all_boss_page.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

import '../r.dart';

class FollowContentPage extends StatefulWidget {
  String label;

  FollowContentPage(this.label, {Key key}) : super(key: key);

  @override
  _FollowContentPageState createState() => _FollowContentPageState();
}

class _FollowContentPageState extends State<FollowContentPage>
    with AutomaticKeepAliveClientMixin {
  var builderFuture;

  List<BossInfoEntity> bossList = []; //boss card列表数据

  StreamSubscription<BaseEvent> eventDispose;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    builderFuture = loadInitData();

    eventBus();
  }

  Future<List<BossInfoEntity>> loadInitData() {
    return BossApi.ins()
        .obtainFollowBossList(widget.label, true)
        .doOnData((event) {
      bossList = event;
    }).doOnError((e) {
      print(e);
    }).last;
  }

  void loadData() {
    BossApi.ins().obtainFollowBossList(widget.label, true).listen((event) {
      bossList = event;
    }, onError: (e) {
      print(e);
    });
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == RefreshFollowEvent) {
        builderFuture = loadInitData();
        setState(() {});
      }
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
        return topWidget();
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
    } else {
      return loadingWidget();
    }
  }

  Widget topWidget() {
    return bossList.isNullOrEmpty() ? emptyCardWidget() : cardWidget();
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
            return cardItemWidget(bossList[index], index);
          },
          itemCount: bossList.length,
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
          ).onClick(() {
            Get.to(() => AllBossPage());
          }),
        ],
      ),
    );
  }

  Widget cardItemWidget(BossInfoEntity entity, int index) {
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
                  child: Image.network(
                    HttpConfig.fullUrl(entity.head),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        index % 2 == 0
                            ? R.assetsImgTestPhoto
                            : R.assetsImgTestHead,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
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
                      entity.updateCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ).positionOn(top: 0, right: 0),
              ],
            ),
          ),
          Text(
            entity.name,
            style: TextStyle(color: BaseColor.textDark, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            entity.role,
            style: TextStyle(color: BaseColor.textGray, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).onClick(() {
      Get.to(() => BossHomePage(), arguments: entity);
    });
  }

  Widget loadingWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          loadCardWidget(),
        ],
      ),
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
}
