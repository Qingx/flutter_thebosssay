import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key key}) : super(key: key);

  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage>
    with AutomaticKeepAliveClientMixin, BasePageController {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  String mCurrentTab;
  bool hasData = false;

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
  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    if (Global.labelList.isNullOrEmpty()) {
      BossApi.ins().obtainBossLabels().flatMap((value) {
        Global.labelList = [BaseEmpty.emptyLabel, ...value];
        mCurrentTab = Global.labelList[0].id;

        return BossApi.ins().obtainAllArticle(pageParam, mCurrentTab);
      }).doOnData((event) {
        hasData = event.hasData;
        concat(event.records, false);
      }).doOnError((e) {
        print(e);
      }).last;
    } else {
      mCurrentTab = Global.labelList[0].id;
      return BossApi.ins()
          .obtainAllArticle(pageParam, mCurrentTab)
          .doOnData((event) {
        hasData = event.hasData;
        concat(event.records, false);
      }).doOnError((e) {
        print(e);
      }).last;
    }
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainAllArticle(pageParam, mCurrentTab).listen((event) {
      hasData = event.hasData;
      concat(event.records, loadMore);
      setState(() {});
    }, onDone: () {
      if (loadMore) {
        controller.finishLoad();
      } else {
        controller.resetLoadState();
        controller.finishRefresh();
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
    return BaseWidget.refreshWidgetPage(
        slivers: [topWidget(), bodyWidget()],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData);
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
      height: 28,
      margin: EdgeInsets.only(top: 12, bottom: 16),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(Global.labelList[index], index);
          },
          itemCount: Global.labelList.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    bool hasSelect = entity.id == mCurrentTab;
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;
    Color bgColor = hasSelect ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = hasSelect ? Colors.white : BaseColor.accent;

    String name = BaseEmpty.emptyLabel == entity ? "全部" : entity.name;
    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          name,
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      if (entity.id != mCurrentTab) {
        mCurrentTab = entity.id;
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
                ArticleEntity entity = mData[index];

                if (entity.files.isNullOrEmpty()) {
                  return ArticleWidget.onlyTextNoContent(
                      entity, index, context);
                } else if (entity.files.length == 1) {
                  return ArticleWidget.singleImgNoContent(
                      entity, index, context);
                } else {
                  return ArticleWidget.adTriImgNoContent(
                      entity, index, context);
                }
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
        180;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Flexible(
                child: Text(content,
                        style:
                            TextStyle(fontSize: 18, color: BaseColor.textGray),
                        textAlign: TextAlign.center)
                    .marginOn(top: 16))
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
