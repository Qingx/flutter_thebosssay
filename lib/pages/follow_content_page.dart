import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/all_boss_page.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../r.dart';

class FollowContentPage extends StatefulWidget {
  String label;

  FollowContentPage(this.label, {Key key}) : super(key: key);

  @override
  _FollowContentPageState createState() => _FollowContentPageState();
}

class _FollowContentPageState extends State<FollowContentPage>
    with AutomaticKeepAliveClientMixin, BasePageController<ArticleEntity> {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  List<BossInfoEntity> bossList = []; //boss card列表数据

  bool hasData = false;
  int totalArticleNumber;

  StreamSubscription<BaseEvent> eventDispose;

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

  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    return BossApi.ins()
        .obtainFollowBossList(widget.label, true)
        .onErrorReturn([]).flatMap((value) {
      bossList = value;

      return BossApi.ins().obtainFollowArticle(pageParam);
    }).doOnData((event) {
      totalArticleNumber = event.total;
      hasData = event.hasData;
      concat(event.records, false);
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();

      BossApi.ins()
          .obtainFollowBossList(widget.label, true)
          .onErrorReturn([]).flatMap((value) {
        bossList = value;

        return BossApi.ins().obtainFollowArticle(pageParam);
      }).listen((event) {
        totalArticleNumber = event.total;
        hasData = event.hasData;
        concat(event.records, loadMore);
        setState(() {});

        controller.finishRefresh(success: true);
      }, onError: (res) {
        controller.finishRefresh(success: false);
      });
    } else {
      BossApi.ins().obtainFollowArticle(pageParam).listen((event) {
        totalArticleNumber = event.total;
        hasData = event.hasData;
        concat(event.records, loadMore);
        setState(() {});

        controller.finishLoad(success: true);
      }, onError: (res, s) {
        controller.finishLoad(success: false);
      });
    }
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == RefreshFollowEvent) {
        controller.callRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WlPage.Page<ArticleEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context,
      AsyncSnapshot<WlPage.Page<ArticleEntity>> snapshot) {
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
      child: BaseWidget.refreshWidgetPage(
          slivers: [sliverWidget(), bodyWidget()],
          controller: controller,
          scrollController: scrollController,
          hasData: hasData,
          loadData: loadData),
    );
  }

  Widget sliverWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return index == 0 ? topWidget() : titleWidget();
        },
        childCount: 2,
      ),
    );
  }

  Widget topWidget() {
    return bossList.isNullOrEmpty() ? emptyCardWidget() : cardWidget();
  }

  Widget cardWidget() {
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
            return cardItemWidget(bossList[index], index);
          },
          itemCount: bossList.length,
        ),
      ),
    );
  }

  Widget emptyCardWidget() {
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

  Widget cardItemWidget(BossInfoEntity entity, int index) {
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
      Get.to(() => BossHomePage(),
          arguments: entity, transition: Transition.rightToLeftWithFade);
    });
  }

  Widget titleWidget() {
    return Container(
      color: BaseColor.pageBg,
      padding: EdgeInsets.only(bottom: 16),
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
            "共${totalArticleNumber ?? 0}篇",
            style: TextStyle(color: BaseColor.textDark, fontSize: 14),
          ).marginOn(left: 12),
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
                ArticleEntity entity = mData[index];

                return entity.files.isNullOrEmpty()
                    ? ArticleWidget.onlyTextWithContent(entity, index, context)
                    : ArticleWidget.singleImgWithContent(
                        entity, index, context);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget emptyBodyWidget() {
    print(MediaQuery.of(context).padding.bottom);
    print(MediaQuery.of(context).size.height);
    print(MediaQuery.of(context).padding.top);

    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        480;

    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Flexible(
              child: Text(
                content,
                style: TextStyle(fontSize: 18, color: BaseColor.textGray),
                textAlign: TextAlign.center,
              ).marginOn(top: 16),
            ),
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
          loadCardWidget(),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(0.9, 8),
          loadingItemWidget(0.7, 8),
          loadingItemWidget(0.4, 8),
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

  Widget loadCardWidget() {
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
