import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/dialog/boss_setting_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/boss_info_page.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class BossHomePage extends StatelessWidget {
  BossHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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

  void onShare(context) {
    showShareDialog(context, onDismiss: () {
      Get.back();
    }, doClick: (index) {
      switch (index) {
        case 0:
          BaseTool.shareToSession();
          break;
        case 1:
          BaseTool.shareToTimeline();
          break;
        default:
          BaseTool.shareCopyLink();
          break;
      }
    });
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
              .onClick(() {
            onShare(context);
          }),
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

  var eventDispose;

  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
    controller?.dispose();

    eventDispose?.cancel();

    TalkingApi.ins().obtainPageEnd("BossHomePage");
  }

  @override
  void initState() {
    super.initState();
    entity = Get.arguments as BossInfoEntity;

    scrollController = ScrollController();
    controller = EasyRefreshController();

    builderFuture = loadInitData();

    TalkingApi.ins().obtainPageStart("BossHomePage");

    eventBus();

    DataConfig.getIns().setBossTime(entity.id, time: entity.updateTime);
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<RefreshFollowEvent>().listen((event) {
      if (entity.id == event.id) {
        entity.isCollect = event.isFollow;
        setState(() {});
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

  void onFollowChange() {
    if (entity.isCollect) {
      cancelFollow();
    } else {
      doFollow();
    }
  }

  void cancelFollow() {
    showFollowAskCancelDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      BaseWidget.showLoadingAlert("尝试取消...", context);

      BossApi.ins().obtainNoFollowBoss(entity.id).listen((event) {
        Get.back();
        Get.back();

        entity.isCollect = false;
        setState(() {});

        BaseWidget.showDoFollowChangeDialog(context, false);

        UserEntity userEntity = Global.user.user.value;
        userEntity.traceNum--;
        Global.user.setUser(userEntity);

        Global.eventBus
            .fire(RefreshFollowEvent(id: entity.id, isFollow: false));

        JpushApi.ins().deleteTags([entity.id]);
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: " 取消失败，${res.msg}");
      });
    });
  }

  void doFollow() {
    BaseWidget.showLoadingAlert("尝试追踪...", context);

    BossApi.ins().obtainFollowBoss(entity.id).listen((event) {
      Get.back();

      entity.isCollect = true;
      setState(() {});

      UserEntity userEntity = Global.user.user.value;
      userEntity.traceNum++;
      Global.user.setUser(userEntity);

      Global.eventBus.fire(RefreshFollowEvent(id: entity.id, isFollow: true));

      JpushApi.ins().addTags([entity.id]);

      showAskPushDialog(context, onConfirm: () {
        Get.back();

        BaseWidget.showDoFollowChangeDialog(context, true);
      }, onDismiss: () {
        Get.back();

        BaseWidget.showDoFollowChangeDialog(context, true);
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: " 追踪失败，${res.msg}");
    });
  }

  void onWatchMore() {
    Get.to(() => BossInfoPage(),
        arguments: entity, transition: Transition.rightToLeftWithFade);
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
                  R.assetsImgDefaultHead,
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
                  "${entity.readCount.formatCountNumber()}阅读·${entity.totalCount ?? 0}篇言论·${entity.collect.formatCountNumber()}关注",
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
              style: TextStyle(color: Colors.white, fontSize: 13),
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 240),
                        child: Text(
                          entity.role,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
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
      padding: EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Ta的言论",
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

                return entity.files.isNullOrEmpty()
                    ? ArticleWidget.onlyTextWithContentBossPage(
                        entity,
                        context,
                        () {
                          if (!entity.isRead) {
                            entity.isRead = false;
                          }

                          if (BaseTool.showRedDots(
                              entity.bossId, entity.getShowTime())) {
                            DataConfig.getIns().setBossTime(entity.bossId);
                          }

                          setState(() {});

                          Get.to(() => WebArticlePage(), arguments: entity.id);
                        },
                      )
                    : ArticleWidget.singleImgWithContentBossPage(
                        entity,
                        context,
                        () {
                          print('entity.isRead=>${entity.isRead}');
                          entity.isRead = true;

                          setState(() {});

                          Get.to(() => WebArticlePage(), arguments: entity.id);
                        },
                      );
              },
              childCount: mData.length,
            ),
          );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        320;
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
