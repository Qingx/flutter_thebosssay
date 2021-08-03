import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/all_boss_page.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class FollowContentPage extends StatefulWidget {
  String label;

  FollowContentPage(this.label, {Key key}) : super(key: key);

  @override
  _FollowContentPageState createState() => _FollowContentPageState();
}

class _FollowContentPageState extends State<FollowContentPage>
    with AutomaticKeepAliveClientMixin {
  var builderFuture;
  List<BossInfoEntity> mData;

  var eventDispose;

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

  void eventBus() {
    eventDispose = Global.eventBus.on<RefreshFollowEvent>().listen((event) {
      loadData();
    });
  }

  Future<List<BossInfoEntity>> loadInitData() {
    return BossApi.ins()
        .obtainFollowBossList(widget.label, true)
        .onErrorReturn([]).doOnData((event) {
      mData = event;
    }).last;
  }

  void loadData() {
    BossApi.ins()
        .obtainFollowBossList(widget.label, true)
        .onErrorReturn([]).listen((event) {
      mData = event;
      setState(() {});
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
    return mData.isNullOrEmpty() ? emptyBossWidget() : bossWidget();
  }

  Widget bossWidget() {
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: 12, bottom: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return bossItemWidget(mData[index], index);
          },
          itemCount: mData.length,
        ),
      ),
    );
  }

  Widget bossItemWidget(BossInfoEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 144,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 4, right: 4),
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
                        R.assetsImgDefaultHead,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Container(
                  height: 16,
                  padding: EdgeInsets.only(left: 8, right: 8),
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

  Widget emptyBossWidget() {
    return Container(
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  Widget loadingWidget() {
    return Container(
      height: 192,
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
