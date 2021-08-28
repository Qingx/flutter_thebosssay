import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/db/article_db_provider.dart';
import 'package:flutter_boss_says/data/db/boss_db_provider.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/boss_batch_tack_event.dart';
import 'package:flutter_boss_says/event/boss_tack_event.dart';
import 'package:flutter_boss_says/event/jpush_article_event.dart';
import 'package:flutter_boss_says/event/scroll_top_event.dart';
import 'package:flutter_boss_says/event/set_boss_time_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/pages/home_boss_all_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

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

    builderFuture = futureData();
    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  void eventBus() {
    tackDispose = Global.eventBus.on<BossTackEvent>().listen((event) {
      if (widget.mLabel == "-1" || event.labels.contains(widget.mLabel)) {
        BossDbProvider.ins()
            .getLastWithLabel(widget.mLabel)
            .onErrorReturn([]).flatMap((value) {
          mBossList = value;
          pageParam.reset();

          return BossApi.ins().obtainTackArticle(pageParam, widget.mLabel);
        }).flatMap((value) {
          hasData = value.hasData;
          totalArticleNumber = value.total;
          concat(value.records, false);

          DataConfig.getIns().tackHasData = hasData;
          DataConfig.getIns().tackTotalNum = totalArticleNumber;

          return ArticleDbProvider.ins().insertList(value.records);
        }).onErrorReturn([]).listen((event) {
          setState(() {});
        });
      }
    });

    tackBatchDispose = Global.eventBus.on<BossBatchTackEvent>().listen((event) {
      BossDbProvider.ins()
          .getLastWithLabel(widget.mLabel)
          .onErrorReturn([]).flatMap((value) {
        mBossList = value;
        pageParam.reset();

        return BossApi.ins().obtainTackArticle(pageParam, widget.mLabel);
      }).flatMap((value) {
        hasData = value.hasData;
        totalArticleNumber = value.total;
        concat(value.records, false);

        DataConfig.getIns().tackHasData = hasData;
        DataConfig.getIns().tackTotalNum = totalArticleNumber;

        return ArticleDbProvider.ins().insertList(value.records);
      }).onErrorReturn([]).listen((event) {
        setState(() {});
      });
    });

    onTopDispose = Global.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (event.pageName == "tack" && event.labelId == widget.mLabel) {
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
    return DataConfig.getIns().fromSplash
        ? widget.mLabel == "-1"
            ? initAllData()
            : initLabelData()
        : initLoginData();
  }

  ///当前页为全部时
  Future<dynamic> initAllData() {
    pageParam?.reset();

    return BossDbProvider.ins()
        .getLastWithLabel(widget.mLabel)
        .onErrorReturn([]).flatMap((value) {
      mBossList = value;

      return ArticleDbProvider.ins().getAll();
    }).doOnData((event) {
      pageParam.next(1);
      totalArticleNumber = DataConfig.getIns().tackTotalNum;
      hasData = DataConfig.getIns().tackHasData;
      concat(event, false);
    }).last;
  }

  ///当前页为其他时
  Future<dynamic> initLabelData() {
    pageParam?.reset();

    return BossDbProvider.ins()
        .getLastWithLabel(widget.mLabel)
        .onErrorReturn([]).flatMap((value) {
      mBossList = value;

      return BossApi.ins().obtainTackArticle(pageParam, widget.mLabel);
    }).doOnData((event) {
      hasData = true;
      totalArticleNumber = event.total;
      concat(event.records, false);
    }).last;
  }

  Future<dynamic> initLoginData() {
    pageParam?.reset();

    return BossApi.ins()
        .obtainFollowBossList("-1", false)
        .onErrorReturn([]).flatMap((value) {
      value = value.where((element) {
        return widget.mLabel == "-1"
            ? BaseTool.isLatest(element.updateTime)
            : element.labels.contains(widget.mLabel) &&
                BaseTool.isLatest(element.updateTime);
      }).toList();

      value.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

      mBossList = value;

      return BossDbProvider.ins().insertList(value);
    }).flatMap((value) {
      return BossApi.ins().obtainTackArticle(pageParam, widget.mLabel);
    }).flatMap((value) {
      hasData = value.hasData;
      totalArticleNumber = value.total;
      concat(value.records, false);

      DataConfig.getIns().tackHasData = hasData;
      DataConfig.getIns().tackTotalNum = totalArticleNumber;

      return widget.mLabel == "-1"
          ? ArticleDbProvider.ins().insertList(value.records)
          : Observable.just(1);
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam?.reset();

      BossApi.ins().obtainFollowBossList("-1", false).flatMap((value) {
        value = value.where((element) {
          return widget.mLabel == "-1"
              ? BaseTool.isLatest(element.updateTime)
              : element.labels.contains(widget.mLabel) &&
                  BaseTool.isLatest(element.updateTime);
        }).toList();

        value.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

        mBossList = value;

        return BossDbProvider.ins().insertList(value);
      }).onErrorReturn([]).flatMap((value) {
        return BossApi.ins().obtainTackArticle(pageParam, widget.mLabel);
      }).flatMap((value) {
        hasData = value.hasData;
        totalArticleNumber = value.total;
        concat(value.records, false);

        DataConfig.getIns().tackTotalNum = totalArticleNumber;
        DataConfig.getIns().tackHasData = hasData;

        return widget.mLabel == "-1"
            ? ArticleDbProvider.ins().insertList(value.records)
            : Observable.just(1);
      }).listen((event) {
        setState(() {});
        controller.finishRefresh(success: true);
      }, onError: (res) {
        controller.finishRefresh(success: false);
      });
    } else {
      BossApi.ins().obtainTackArticle(pageParam, widget.mLabel).listen((event) {
        hasData = event.hasData;
        concat(event.records, true);
        setState(() {});

        controller.finishLoad(success: true);
      }, onError: (res) {
        controller.finishLoad(success: false);
      });
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
          builderFuture = futureData();
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
              Global.user.user.value.traceNum == 0 ? "还没有追踪的老板" : "追踪的老板暂无言论更新",
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
                "立即添加",
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
                ArticleSimpleEntity entity = mData[index];

                return entity.files.isNullOrEmpty()
                    ? ArticleWidget.onlyTextWithContentS(entity, context)
                    : ArticleWidget.singleImgWithContentS(entity, context);
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
