import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/speech_track_boss_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
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
    with AutomaticKeepAliveClientMixin, BasePageController<ArticleEntity> {
  Future<bool> builderFuture;
  int mCurrentIndex;

  List<BossLabelEntity> mLabels;
  List<SpeechTrackBossPage> mPages;
  bool hasData;
  int totalArticleNumber;

  PageController mPageController;
  ScrollController scrollController;
  EasyRefreshController controller;

  var eventDispose;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    mPageController?.dispose();
    controller?.dispose();
    scrollController?.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    mCurrentIndex = 0;
    mLabels = [];
    mPages = [];
    hasData = false;
    totalArticleNumber = 0;

    builderFuture = loadInitData();

    mPageController = PageController();
    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<RefreshFollowEvent>().listen((event) {
      controller.callRefresh();
    });
  }

  Future<bool> loadInitData() {
    pageParam?.reset();
    bool canUse = !DataConfig.getIns().bossLabels.isLabelEmpty();

    if (canUse) {
      return BossApi.ins().obtainFollowArticle(pageParam).flatMap((value) {
        mLabels = DataConfig.getIns().bossLabels;
        mPages = mLabels.map((e) => SpeechTrackBossPage(e.id)).toList();

        hasData = value.hasData;
        totalArticleNumber = value.total;
        concat(value.records, false);

        return Observable.just(true);
      }).last;
    } else {
      return BossApi.ins().obtainBossLabels().flatMap((value) {
        value = [BaseEmpty.emptyLabel, ...value];
        mLabels = value;

        DataConfig.getIns().setBossLabels = mLabels;
        mPages = mLabels.map((e) => SpeechTrackBossPage(e.id)).toList();

        return BossApi.ins().obtainFollowArticle(pageParam);
      }).flatMap((value) {
        hasData = value.hasData;
        totalArticleNumber = value.total;
        concat(value.records, false);

        return Observable.just(!mLabels.isLabelEmpty());
      }).last;
    }
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainFollowArticle(pageParam).listen((event) {
      totalArticleNumber = event.total;
      hasData = event.hasData;
      concat(event.records, loadMore);
      setState(() {});

      if (loadMore) {
        controller.finishLoad(success: true);
      } else {
        controller.finishRefresh(success: true);
      }
    }, onError: (res) {
      if (loadMore) {
        controller.finishLoad(success: false);
      } else {
        controller.finishRefresh(success: false);
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

  Widget builderWidget(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data) {
        Global.hint.setCanUse(true);
        return contentWidget();
      } else {
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
      }
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        children: [
          tabWidget(),
          Expanded(
            child: BaseWidget.refreshWidgetPage(
              slivers: [sliverWidget(), bodyWidget()],
              controller: controller,
              scrollController: scrollController,
              hasData: hasData,
              loadData: loadData,
            ),
          ),
        ],
      ),
    );
  }

  Widget sliverWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return index == 0 ? bossWidget() : titleWidget();
        },
        childCount: 2,
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      color: BaseColor.pageBg,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget bossWidget() {
    return Container(
      height: 180,
      child: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: mPageController,
        itemCount: mPages.length,
        itemBuilder: (context, index) {
          return mPages[index];
        },
        onPageChanged: (index) {
          mCurrentIndex = index;
          setState(() {});
        },
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
            return tabItemWidget(mLabels[index], index);
          },
          itemCount: mLabels.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == mLabels.length - 1 ? 16 : 8;

    bool hasSelect = mLabels[mCurrentIndex].id == entity.id;

    Color bgColor = hasSelect ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = hasSelect ? Colors.white : BaseColor.accent;

    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          entity.name,
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      if (index != mCurrentIndex) {
        mCurrentIndex = index;
        mPageController.jumpToPage(mCurrentIndex);
      }
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 480),
        curve: Curves.ease,
      );
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
          loadingItemWidget(0.9, 8),
          loadingItemWidget(0.7, 8),
          loadingItemWidget(0.4, 8),
        ],
      ),
    );
  }

  Widget loadTabWidget() {
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
            return loadTabItemWidget(index);
          },
          itemCount: 6,
        ),
      ),
    );
  }

  Widget loadTabItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 5 ? 16 : 8;

    return Container(
      width: 56,
      height: 28,
      margin: EdgeInsets.only(left: left, right: right),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        color: BaseColor.loadBg,
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
