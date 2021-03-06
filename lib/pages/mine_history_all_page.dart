import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/history_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class MineHistoryAllPage extends StatefulWidget {
  const MineHistoryAllPage({Key key}) : super(key: key);

  @override
  _MineHistoryAllPageState createState() => _MineHistoryAllPageState();
}

class _MineHistoryAllPageState extends State<MineHistoryAllPage>
    with BasePageController<HistoryEntity> {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = false;

  StreamSubscription<BaseEvent> eventDispose;

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();

    eventDispose?.cancel();

    TalkingApi.ins().obtainPageEnd(TalkingApi.HistoryAll);
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    builderFuture = loadInitData();

    TalkingApi.ins().obtainPageStart(TalkingApi.HistoryAll);
  }

  Future<WlPage.Page<HistoryEntity>> loadInitData() {
    return AppApi.ins().obtainHistoryList(pageParam, false).doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    AppApi.ins().obtainHistoryList(pageParam, false).listen((event) {
      hasData = event.hasData;
      concat(event.records, loadMore);
      setState(() {});

      if (loadMore) {
        controller.finishLoad(success: true);
      } else {
        controller.finishRefresh(success: true);
      }
    }).onError((res) {
      if (loadMore) {
        controller.finishLoad(success: false);
      } else {
        controller.finishRefresh(success: false);
      }
    });
  }

  ///??????????????????
  void removeHistory(HistoryEntity entity, int index) {
    BaseWidget.showLoadingAlert("????????????...", context);

    AppApi.ins().obtainDeleteHistory(entity.id).listen((event) {
      Get.back();

      mData.removeAt(index);
      setState(() {});
    }, onError: (res) {
      Get.back();
      print(res.msg);
      BaseTool.toast(msg: "???????????????${res.msg}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseColor.pageBg,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: [
            Container(
              color: BaseColor.loadBg,
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              color: BaseColor.loadBg,
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
                        "????????????",
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
            Expanded(child: bodyWidget()),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget() {
    return FutureBuilder<WlPage.Page<HistoryEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context,
      AsyncSnapshot<WlPage.Page<HistoryEntity>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidgetPage(
        slivers: [
          listWidget(),
        ],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData,
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
                var entity = mData[index];
                return entity.hidden
                    ? articleHiddenItem(entity, index)
                    : articleItemWidget(entity, index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget articleItemWidget(HistoryEntity entity, index) {
    String head = index % 2 == 0 ? R.assetsImgTestPhoto : R.assetsImgTestHead;
    return Container(
      child: Column(
        children: [
          Slidable(
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.articleTitle ?? "????????????",
                    style: TextStyle(fontSize: 14, color: BaseColor.textDark),
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipOval(
                        child: Image.network(
                          HttpConfig.fullUrl(entity.bossHead),
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              head,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Text(
                        entity.bossName ?? "?????????",
                        style:
                            TextStyle(fontSize: 14, color: BaseColor.textGray),
                        softWrap: false,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).marginOn(left: 8),
                      Expanded(child: SizedBox()),
                      Text(
                        DateFormat.getMMDDHHMM(entity.updateTime),
                        style: TextStyle(
                          fontSize: 13,
                          color: BaseColor.textGray,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ).marginOn(top: 8),
                ],
              ),
            ),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '??????',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  removeHistory(entity, index);
                },
              ),
            ],
          ),
          Visibility(
            child: Container(
              height: 1,
              color: BaseColor.line,
            ),
            visible: index != mData.length - 1,
          )
        ],
      ),
    ).onClick(() {
      Get.to(() => WebArticlePage(fromBoss: false),
          arguments: entity.articleId);
    });
  }

  Widget articleHiddenItem(HistoryEntity entity, index) {
    String head = index % 2 == 0 ? R.assetsImgTestPhoto : R.assetsImgTestHead;
    return Container(
      child: Column(
        children: [
          Slidable(
            child: Container(
              color: BaseColor.line,
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Boss??????????????????????????????",
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipOval(
                        child: Image.network(
                          HttpConfig.fullUrl(entity.bossHead),
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              head,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Text(
                        entity.bossName ?? "?????????",
                        style:
                            TextStyle(fontSize: 14, color: BaseColor.textGray),
                        softWrap: false,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).marginOn(left: 8),
                      Expanded(child: SizedBox()),
                    ],
                  ).marginOn(top: 8),
                ],
              ),
            ),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '??????',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  removeHistory(entity, index);
                },
              ),
            ],
          ),
          Visibility(
            child: Container(
              height: 1,
              color: BaseColor.line,
            ),
            visible: index != mData.length - 1,
          )
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "???????????????????????????";
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
}
