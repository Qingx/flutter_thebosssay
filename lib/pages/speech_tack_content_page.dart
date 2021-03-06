import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/event/boss_batch_tack_event.dart';
import 'package:flutter_boss_says/event/boss_tack_event.dart';
import 'package:flutter_boss_says/event/global_scroll_event.dart';
import 'package:flutter_boss_says/event/jpush_article_event.dart';
import 'package:flutter_boss_says/event/page_scroll_event.dart';
import 'package:flutter_boss_says/event/set_boss_time_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/pages/home_boss_all_page.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class SpeechTackContentPage extends StatefulWidget {
  String mLabel;

  SpeechTackContentPage(this.mLabel, {Key key}) : super(key: key);

  @override
  _SpeechTackContentPageState createState() => _SpeechTackContentPageState();
}

class _SpeechTackContentPageState extends State<SpeechTackContentPage>
    with
        AutomaticKeepAliveClientMixin,
        BasePageController<ArticleSimpleEntity> {
  var builderFuture;

  bool hasData;
  int totalArticleNumber;
  List<BossSimpleEntity> mBossList;
  String titleText;

  ScrollController scrollController;
  EasyRefreshController controller;

  var tackDispose;
  var tackBatchDispose;
  var onTopDispose;
  var articleDispose;
  var bossTimeDispose;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();

    tackDispose?.cancel();
    tackBatchDispose?.cancel();
    onTopDispose?.cancel();
    articleDispose?.cancel();
    bossTimeDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    hasData = false;
    totalArticleNumber = 0;
    mBossList = [];
    titleText = "????????????";

    builderFuture = futureData();
    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  void eventBus() {
    tackDispose = Global.eventBus.on<BossTackEvent>().listen((event) {
      if (event.labels.contains(widget.mLabel)) {
        AppApi.ins()
            .obtainGetTackArticleList(pageParam, widget.mLabel)
            .onErrorReturn(BaseEmpty.emptyArticle)
            .listen((event) {
          mBossList =
              CacheProvider.getIns().getBossWithLastByLabel(widget.mLabel);
          mBossList.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

          hasData = event.hasData;
          totalArticleNumber = event.total;
          concat(event.records, false);
          titleText = event?.records[0]?.recommendType == "0" ? "????????????" : "????????????";
          setState(() {});
        });
      }
    });

    tackBatchDispose = Global.eventBus.on<BossBatchTackEvent>().listen((event) {
      AppApi.ins()
          .obtainGetTackArticleList(pageParam, widget.mLabel)
          .onErrorReturn(BaseEmpty.emptyArticle)
          .listen((event) {
        mBossList =
            CacheProvider.getIns().getBossWithLastByLabel(widget.mLabel);
        mBossList.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

        hasData = event.hasData;
        totalArticleNumber = event.total;
        concat(event.records, false);
        titleText = event?.records[0]?.recommendType == "0" ? "????????????" : "????????????";
        setState(() {});
      });
    });

    onTopDispose = Global.eventBus.on<PageScrollEvent>().listen((event) {
      if (GlobalScrollEvent.talkPage == "tack" &&
          GlobalScrollEvent.tackLabel == widget.mLabel) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 480),
          curve: Curves.ease,
        );
      }
    });

    articleDispose = Global.eventBus.on<JpushArticleEvent>().listen((event) {
      var index = mBossList.indexWhere((element) => element.id == event.bossId);

      if (index != -1) {
        mBossList[index].updateTime = event.updateTime;
        setState(() {});
      }
    });

    bossTimeDispose = Global.eventBus.on<SetBossTimeEvent>().listen((event) {
      var index = mBossList.indexWhere((element) => element.id == event.bossId);

      if (index != -1) {
        setState(() {});
      }
    });
  }

  Future<dynamic> futureData() {
    return DataConfig.getIns().fromSplash ? initLabelData() : initLogoutData();
  }

  ///?????????????????????
  Future<dynamic> initLabelData() {
    pageParam?.reset();
    DataConfig.getIns().fromSplash = true;

    return AppApi.ins()
        .obtainGetTackArticleList(pageParam, widget.mLabel)
        .onErrorReturn(BaseEmpty.emptyArticle)
        .doOnData((event) {
      mBossList = CacheProvider.getIns().getBossWithLastByLabel(widget.mLabel);
      DataConfig.getIns().fromSplash = true;

      hasData = true;
      totalArticleNumber = event.total;
      concat(event.records, false);
      titleText = event?.records[0]?.recommendType == "0" ? "????????????" : "????????????";
    }).last;
  }

  Future<dynamic> initLogoutData() {
    pageParam?.reset();

    return AppApi.ins()
        .obtainGetTackArticleList(pageParam, widget.mLabel)
        .onErrorReturn(BaseEmpty.emptyArticle)
        .doOnData((value) {
      mBossList = [];
      DataConfig.getIns().fromSplash = true;

      hasData = value.hasData;
      totalArticleNumber = value.total;
      concat(value.records, false);
      titleText = "????????????";
    }).last;
  }

  Future<dynamic> initErrorLoad() {
    pageParam?.reset();
    DataConfig.getIns().fromSplash = true;

    return AppApi.ins()
        .obtainGetTackArticleList(pageParam, widget.mLabel)
        .onErrorReturn(BaseEmpty.emptyArticle)
        .doOnData((value) {
      mBossList = CacheProvider.getIns().getBossWithLastByLabel(widget.mLabel);

      hasData = value.hasData;
      totalArticleNumber = value.total;
      concat(value.records, false);
      titleText = value?.records[0]?.recommendType == "0" ? "????????????" : "????????????";
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam?.reset();

      AppApi.ins()
          .obtainGetAllFollowBoss("-1")
          .onErrorReturn([])
          .flatMap((value) {
            CacheProvider.getIns().insertBossList(value);
            if (!value.isNullOrEmpty()) {
              value = value
                  .where((element) =>
                      element.labels.contains(widget.mLabel) &&
                      BaseTool.isLatest(element.updateTime) &&
                      BaseTool.showRedDots(element.id, element.updateTime))
                  .toList();
            }
            value.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

            mBossList = value;

            return AppApi.ins()
                .obtainGetTackArticleList(pageParam, widget.mLabel);
          })
          .onErrorReturn(BaseEmpty.emptyArticle)
          .listen((event) {
            hasData = event.hasData;
            totalArticleNumber = event.total;
            titleText =
                event?.records[0]?.recommendType == "0" ? "????????????" : "????????????";
            concat(event.records, false);

            setState(() {});
            controller.finishRefresh(success: true);
          }, onError: (res) {
            controller.finishRefresh(success: false);
          });
    } else {
      AppApi.ins().obtainGetTackArticleList(pageParam, widget.mLabel).listen(
          (event) {
        hasData = event.hasData;
        concat(event.records, true);
        setState(() {});

        controller.finishLoad(success: true);
      }, onError: (res) {
        controller.finishLoad(success: false);
      });
    }
  }

  ///???????????????
  void onArticleClick(String id) {
    Get.to(() => WebArticlePage(fromBoss: false), arguments: id);
    var index = mData.indexWhere((element) => element.id == id);
    if (index != -1) {
      mData[index].isRead = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else {
        return BaseWidget.errorWidget(() {
          builderFuture = initErrorLoad();
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
      child: BaseWidget.refreshWidgetPage(
        slivers: [sliverWidget(), bodyWidget()],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData,
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

  Widget bossWidget() {
    return mBossList.isNullOrEmpty()
        ? emptyBossWidget()
        : Container(
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
                  return bossItemWidget(mBossList[index], index);
                },
                itemCount: mBossList.length,
              ),
            ),
          );
  }

  Widget bossItemWidget(BossSimpleEntity entity, int index) {
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
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: BaseTool.showRedDots(entity.id, entity.updateTime)
                        ? Colors.red
                        : Colors.transparent,
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
      Get.to(() => BossHomePage(), arguments: entity.id);
      mBossList.removeAt(index);
      setState(() {});
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
          Obx(
            () => Text(
              Global.user.user.value.traceNum == 0 ? "????????????????????????" : "?????????????????????????????????",
              style: TextStyle(fontSize: 14, color: Color(0x80000000)),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
            ),
          ),
          Container(
            height: 28,
            width: 120,
            decoration: BoxDecoration(
                border: Border.all(color: BaseColor.accent, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(
              child: Text(
                "????????????",
                style: TextStyle(fontSize: 16, color: BaseColor.accent),
                textAlign: TextAlign.center,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ).onClick(() {
            Get.to(() => HomeBossAllPage());
          }),
        ],
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
            titleText,
            style: TextStyle(
                color: BaseColor.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ).marginOn(left: 16),
          Text(
            "???${totalArticleNumber ?? 0}???",
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
                ArticleSimpleEntity entity = mData[index];

                return entity.files.isNullOrEmpty()
                    ? ArticleWidget.onlyTextWithContentS(
                        entity, context, onArticleClick)
                    : ArticleWidget.singleImgWithContentS(
                        entity, context, onArticleClick);
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
    String content = "???????????????????????????";
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
