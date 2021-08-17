import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/event/scroll_top_event.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class SpeechSquareContentPage extends StatefulWidget {
  String label;

  SpeechSquareContentPage(this.label, {Key key}) : super(key: key);

  @override
  _SpeechSquareContentPageState createState() =>
      _SpeechSquareContentPageState();
}

class _SpeechSquareContentPageState extends State<SpeechSquareContentPage>
    with AutomaticKeepAliveClientMixin, BasePageController<ArticleEntity> {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  bool hasData = false;

  var eventDispose;

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

  void eventBus() {
    eventDispose = Global.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (event.pageName == "square" && event.labelId == widget.label) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 480),
          curve: Curves.ease,
        );
      }
    });
  }

  ///初始化获取数据
  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    return BossApi.ins()
        .obtainAllArticle(pageParam, widget.label)
        .doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).doOnError((e) {
      print(e);
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainAllArticle(pageParam, widget.label).listen((event) {
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
      slivers: [
        bannerWidget(),
        bodyWidget(),
      ],
      controller: controller,
      scrollController: scrollController,
      hasData: hasData,
      loadData: loadData,
    );
  }

  Widget bannerWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            height: 144,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Swiper(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Image.asset(
                    R.assetsImgTestPhoto,
                    fit: BoxFit.cover,
                  );
                },
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: 2),
                  builder: DotSwiperPaginationBuilder(
                    activeColor: BaseColor.accent,
                    color: BaseColor.pageBg,
                    size: 6,
                    activeSize: 6,
                  ),
                ),
                autoplay: true,
                autoplayDelay: 4000,
                autoplayDisableOnInteraction: true,
              ),
            ),
          );
        },
        childCount: 1,
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
                    ? ArticleWidget.onlyTextNoContent(entity, context)
                    : ArticleWidget.singleImgNoContent(entity, context);
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
        240;
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
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.6, 8),
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
}
