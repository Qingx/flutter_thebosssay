import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/article_read_event.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';

class BossArticlePage extends StatefulWidget {
  String type;
  String bossId;
  int total;

  BossArticlePage({this.type, this.bossId, this.total, Key key})
      : super(key: key);

  @override
  _BossArticlePageState createState() => _BossArticlePageState();
}

class _BossArticlePageState extends State<BossArticlePage>
    with
        BasePageController<ArticleSimpleEntity>,
        AutomaticKeepAliveClientMixin {
  int totalNum;
  bool hasData;

  EasyRefreshController controller;

  var builderFuture;
  var readDispose;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    readDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController();
    eventBus();

    builderFuture = initData();
  }

  void eventBus() {
    readDispose = Global.eventBus.on<ArticleReadEvent>().listen((event) {
      int index = mData.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        mData[index].isRead = true;
        setState(() {});
      }
    });
  }

  Future<dynamic> initData() {
    pageParam?.reset();

    return BossApi.ins()
        .obtainBossArticle(pageParam, widget.bossId, widget.type)
        .doOnData((event) {
      hasData = event.hasData;
      totalNum = event.total;
      concat(event.records, false);
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam?.reset();
    }

    BossApi.ins()
        .obtainBossArticle(pageParam, widget.bossId, widget.type)
        .listen((event) {
      hasData = event.hasData;
      totalNum = event.total;
      concat(event.records, loadMore);

      if (loadMore) {
        controller.finishLoad(success: true);
      } else {
        controller.finishRefresh(success: true);
      }

      setState(() {});
    }, onError: (res) {
      if (loadMore) {
        controller.finishLoad(success: false);
      } else {
        controller.finishRefresh(success: false);
      }
    });
  }

  void onArticleClick(ArticleSimpleEntity entity) {
    if (!entity.isRead) {
      entity.isRead = true;
    }

    if (BaseTool.showRedDots(entity.bossId, entity.getShowTime())) {
      DataConfig.getIns().setBossTime(entity.bossId);
    }

    setState(() {});

    Get.to(() => WebArticlePage(fromBoss: true), arguments: entity.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else {
        return BaseWidget.errorWidget(() {
          builderFuture = initData();
          setState(() {});
        });
      }
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return BaseWidget.refreshWidgetPage(
      controller: controller,
      hasData: hasData,
      loadData: loadData,
      slivers: [
        noticeWidget(),
        listWidget(),
      ],
    );
  }

  Widget noticeWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            height: 56,
            padding: EdgeInsets.only(bottom: 12, top: 12),
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              padding: EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: BaseColor.loadBg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "收录Boss自己的言论、演说稿件、采访答录等",
                      style: TextStyle(color: BaseColor.textDark, fontSize: 12),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "共${widget.total}篇",
                    style: TextStyle(color: BaseColor.textDark, fontSize: 12),
                  ).marginOn(left: 8),
                ],
              ),
            ),
          );
        },
        childCount: 1,
      ),
    );
  }

  Widget listWidget() {
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

                return articleWidget(entity);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget articleWidget(ArticleSimpleEntity entity) {
    return entity.files.isNullOrEmpty()
        ? ArticleWidget.onlyTextWithContentBossPage(entity, context, () {
            onArticleClick(entity);
          })
        : ArticleWidget.singleImgWithContentBossPage(entity, context, () {
            onArticleClick(entity);
          });
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        232 -
        40 -
        56;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Text(
              content,
              style: TextStyle(fontSize: 18, color: BaseColor.textGray),
              textAlign: TextAlign.center,
            ).marginOn(top: 16),
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
    });
  }
}
