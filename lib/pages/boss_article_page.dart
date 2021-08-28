import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/util/base_extension.dart';

class BossArticlePage extends StatefulWidget {
  String bossId = Get.arguments as String;

  BossArticlePage({Key key}) : super(key: key);

  @override
  _BossArticlePageState createState() => _BossArticlePageState();
}

class _BossArticlePageState extends State<BossArticlePage>
    with BasePageController<ArticleEntity> {
  int totalArticle;
  bool hasInit;
  bool hasData;

  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    totalArticle = 0;
    hasInit = false;
    hasData = false;

    builderFuture = initData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  Future<WlPage.Page<ArticleEntity>> initData() {
    return BossApi.ins()
        .obtainBossArticleList(pageParam, widget.bossId)
        .doOnData((event) {
      hasInit = true;
      hasData = event.hasData;
      totalArticle = event.total;
      concat(event.records, false);

      setState(() {});
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam?.reset();
    }

    BossApi.ins().obtainBossArticleList(pageParam, widget.bossId).listen(
        (event) {
      totalArticle = event.total;
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

  void onArticleClick(ArticleEntity entity) {
    if (!entity.isRead) {
      entity.isRead = true;
    }

    if (BaseTool.showRedDots(entity.bossId, entity.getShowTime())) {
      DataConfig.getIns().setBossTime(entity.bossId);
    }

    setState(() {});

    if (!entity.isRead) {
      BaseTool.doAddRead();
    }

    Get.to(() => WebArticlePage(fromBoss: true), arguments: entity.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              color: Colors.white,
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 28),
                      alignment: Alignment.center,
                      child: Text(
                        hasInit ? "全部文章($totalArticle篇)" : "全部文章",
                        style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bodyWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget() {
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
          builderFuture = initData();
          setState(() {});
        });
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return BaseWidget.refreshWidgetPage(
      slivers: [
        listWidget(),
      ],
      controller: controller,
      scrollController: scrollController,
      hasData: hasData,
      loadData: loadData,
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
                ArticleEntity entity = mData[index];

                return entity.files.isNullOrEmpty()
                    ? ArticleWidget.onlyTextWithContentBoss(entity, context,
                        () {
                        onArticleClick(entity);
                      })
                    : ArticleWidget.singleImgWithContentBoss(entity, context,
                        () {
                        onArticleClick(entity);
                      });
              },
              childCount: mData.length,
            ),
          );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = " 最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        44;
    return Container(
      height: height,
      child: Center(
        child: Column(
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
            )
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
    });
  }
}
