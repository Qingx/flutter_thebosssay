import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/dialog/boss_setting_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_success_dialog.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/event/refresh_user_event.dart';
import 'package:flutter_boss_says/pages/boss_info_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class BossHomePage extends StatelessWidget {
  BossHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Stack(
          children: [
            BodyWidget(),
            topBar(context),
          ],
        ),
      ),
    );
  }

  void onBack() {
    Get.back();
  }

  void onShare() {
    Share.share('https://www.bilibili.com/');
  }

  void onSetting(BuildContext context) {
    showBossSettingDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      BaseTool.toast(msg: "开启推送");
      Get.back();
    });
  }

  Widget topBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back, size: 26, color: Colors.white)
              .marginOn(left: 16)
              .onClick(onBack),
          Expanded(child: SizedBox()),
          Image.asset(R.assetsImgShareWhite, width: 24, height: 24)
              .marginOn(right: 20)
              .onClick(onShare),
          Image.asset(R.assetsImgSettingWhite, width: 24, height: 24)
              .marginOn(right: 16)
              .onClick(() {
            onSetting(context);
          }),
        ],
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({Key key}) : super(key: key);

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> with BasePageController {
  var builderFuture;
  bool hasData = true;

  ScrollController scrollController;
  EasyRefreshController controller;

  BossInfoEntity entity;

  StreamSubscription<BaseEvent> eventDispose;

  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
    controller?.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    entity = Get.arguments as BossInfoEntity;

    scrollController = ScrollController();
    controller = EasyRefreshController();

    builderFuture = loadInitData();

    eventBus();
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      ///添加追踪boss后刷新
      if (event.obj == RefreshFollowEvent) {
        BossApi.ins().obtainBossDetail(entity.id).listen((event) {
          entity = event;
          setState(() {});
        });
      }

      ///添加收藏文章后刷新
      if (event.obj == RefreshCollectEvent) {
        // controller?.callRefresh();
      }
    });
  }

  ///初始化获取数据
  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    return BossApi.ins()
        .obtainBossArticleList(pageParam, entity.id)
        .doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).doOnError((res) {
      print(res.msg);
    }).last;
  }

  ///获取boss文章列表
  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainBossArticleList(pageParam, entity.id).listen((event) {
      hasData = event.hasData;
      concat(event.records, loadMore);

      setState(() {});
    }, onError: (res) {
      print(res.msg);
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
    return Container(
      child: Column(
        children: [
          topWidget(),
          numberWidget(),
          Expanded(
            child: FutureBuilder<WlPage.Page<ArticleEntity>>(
              builder: builderWidget,
              future: builderFuture,
            ),
          ),
        ],
      ),
    );
  }

  void onFollowChange() {
    if (entity.isCollect) {
      cancelFollow();
    } else {
      doFollow();
    }
  }

  void cancelFollow() {
    BaseWidget.showLoadingAlert("尝试取消...", context);
    BossApi.ins().obtainNoFollowBoss(entity.id).listen((event) {
      Get.back();

      entity.isCollect = false;
      setState(() {});

      Global.eventBus.fire(BaseEvent(RefreshFollowEvent));
      Global.eventBus.fire(BaseEvent(RefreshUserEvent));

      showFollowCancelDialog(context, onDismiss: () {
        Get.back();
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: " 取消失败，${res.msg}");
    });
  }

  void doFollow() {
    BaseWidget.showLoadingAlert("尝试追踪...", context);

    BossApi.ins().obtainFollowBoss(entity.id).listen((event) {
      Get.back();

      entity.isCollect = true;
      setState(() {});

      Global.eventBus.fire(BaseEvent(RefreshUserEvent));
      Global.eventBus.fire(BaseEvent(RefreshFollowEvent));

      showFollowSuccessDialog(context, onConfirm: () {
        Get.back();
      }, onDismiss: () {
        Get.back();
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: " 追踪失败，${res.msg}");
    });
  }

  void onWatchMore() {
    Get.to(() => BossInfoPage(), arguments: entity);
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
      return BaseWidget.loadingWidget();
    }
  }

  Widget topWidget() {
    return Container(
      height: MediaQuery.of(context).padding.top + 40 + 160,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(R.assetsImgBossTopBg),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bossInfoWidget(),
          bossInfoBottomWidget(),
        ],
      ),
    );
  }

  Widget bossInfoWidget() {
    return Container(
      height: 64,
      margin: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.network(
              HttpConfig.fullUrl(entity.head),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  R.assetsImgTestPhoto,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  entity.name,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  softWrap: false,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  "${entity.point ?? 0}万阅读·${entity.totalCount ?? 0}篇言论",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).marginOn(left: 16),
          ),
        ],
      ),
    );
  }

  Widget bossInfoBottomWidget() {
    bool hasFollow = entity.isCollect;
    Color followColor = hasFollow ? Color(0x80efefef) : Colors.red;

    return Container(
      margin: EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: followColor,
            ),
            child: Text(
              hasFollow ? "已追踪" : "追踪",
              style: TextStyle(color: Colors.white, fontSize: 14),
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ).onClick(onFollowChange),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 1),
                      margin: EdgeInsets.only(left: 8, right: 16),
                      decoration: BoxDecoration(
                        color: Color(0x80000000),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entity.role,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  "个人简介：${entity.info}",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  softWrap: true,
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16, top: 8).onClick(() {
                  onWatchMore();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget numberWidget() {
    return Container(
      height: 56,
      padding: EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "ta的言论",
            style: TextStyle(
                fontSize: 24,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "共${entity.totalCount ?? 0}篇",
            style: TextStyle(fontSize: 14, color: BaseColor.textDark),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ).marginOn(left: 12),
        ],
      ),
    );
  }

  Widget contentWidget() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: BaseWidget.refreshWidgetPage(
        slivers: [bodyWidget()],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData,
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

                if (entity.files.isNullOrEmpty()) {
                  return ArticleWidget.onlyTextWithContent(
                      entity, index, context);
                } else {
                  return ArticleWidget.singleImgWithContent(
                      entity, index, context);
                }
              },
              childCount: mData.length,
            ),
          );
  }

  Widget adWidget() {
    return Container(
      height: 160,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(R.assetsImgTestPhoto),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(4)),
        ),
      ),
    );
  }

  Widget bodyItemWidget(index) {
    bool hasLike = index % 2 == 0;
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    return Container(
      height: 216,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.white),
      child: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  height: 128,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage(R.assetsImgTestHead),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(4),
                        topEnd: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              color: BaseColor.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: BaseColor.accent,
                          ),
                          Text(
                            "19.9w",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ).marginOn(left: 8),
                          Expanded(child: SizedBox()),
                          Icon(
                            hasLike ? Icons.star : Icons.star_border_outlined,
                            size: 16,
                            color: hasLike ? Colors.orange : BaseColor.textGray,
                          ).marginOn(right: 8),
                          Text(
                            "1230",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ).marginOn(bottom: 8, left: 8, right: 8)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "2020/5/30",
            style: TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).positionOn(top: 12, left: 0, right: 0),
        ],
      ),
    );
  }

  Widget bodyItemLargeWidget(index) {
    bool hasLike = index % 2 == 0;
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    return Container(
      height: 304,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.white),
      child: Stack(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 224,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage(R.assetsImgTestSplash),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(4),
                        topEnd: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              color: BaseColor.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: BaseColor.accent,
                          ),
                          Text(
                            "19.9w",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ).marginOn(left: 8),
                          Expanded(child: SizedBox()),
                          Icon(
                            hasLike ? Icons.star : Icons.star_border_outlined,
                            size: 16,
                            color: hasLike ? Colors.orange : BaseColor.textGray,
                          ).marginOn(right: 8),
                          Text(
                            "1230",
                            style: TextStyle(
                                fontSize: 12, color: BaseColor.textGray),
                            softWrap: false,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ).marginOn(bottom: 8, left: 8, right: 8)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "2020/5/30",
            style: TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).positionOn(top: 12, left: 0, right: 0),
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        256;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Text(content,
                    style: TextStyle(fontSize: 18, color: BaseColor.textGray),
                    textAlign: TextAlign.center)
                .marginOn(top: 16),
          ],
        ),
      ),
    ).onClick(() {
      print('controller.callRefresh()');
      controller.callRefresh();
    });
  }
}
