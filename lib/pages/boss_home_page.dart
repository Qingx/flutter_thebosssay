import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/db/boss_db_provider.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/dialog/boss_setting_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/boss_tack_event.dart';
import 'package:flutter_boss_says/event/set_boss_time_event.dart';
import 'package:flutter_boss_says/pages/boss_article_page.dart';
import 'package:flutter_boss_says/pages/boss_info_page.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BossHomePage extends StatefulWidget {
  String bossId = Get.arguments as String;

  BossHomePage({Key key}) : super(key: key);

  @override
  _BossHomePageState createState() => _BossHomePageState();
}

class _BossHomePageState extends State<BossHomePage> {
  BossInfoEntity bossEntity;
  String mCurrentType;
  HashMap<String, List<ArticleSimpleEntity>> map;

  List<String> typeList;

  var builderFuture;

  var tackDispose;

  @override
  void dispose() {
    super.dispose();

    tackDispose?.cancel();

    DataConfig.getIns().setBossTime(widget.bossId);
    Global.eventBus.fire(SetBossTimeEvent(widget.bossId));

    TalkingApi.ins().obtainPageEnd(TalkingApi.BossHome);
  }

  @override
  void initState() {
    super.initState();

    bossEntity = BossInfoEntity();
    mCurrentType = "1";
    map = HashMap();

    typeList = ["言论演说", "新闻资讯", "传记其他"];

    builderFuture = initData();

    TalkingApi.ins().obtainPageStart(TalkingApi.BossHome);

    eventBus();
  }

  void eventBus() {
    tackDispose = Global.eventBus.on<BossTackEvent>().listen((event) {
      if (widget.bossId == event.id) {
        bossEntity.isCollect = event.isFollow;
        setState(() {});
      }
    });
  }

  Future<dynamic> initData() {
    return BossApi.ins().obtainBossDetail(widget.bossId).flatMap((value) {
      bossEntity = value;

      return BossApi.ins().obtainBossArticle(widget.bossId, mCurrentType);
    }).doOnData((event) {
      map["1"] = event;
    }).last;
  }

  void onTabClick(int index) {
    if (mCurrentType != (index + 1).toString()) {
      mCurrentType = (index + 1).toString();

      if (map[mCurrentType].isNullOrEmpty()) {
        BossApi.ins()
            .obtainBossArticle(widget.bossId, mCurrentType)
            .onErrorReturn([]).listen((event) {
          map[mCurrentType] = event;
          setState(() {});
        });
      } else {
        setState(() {});
      }
    }
  }

  void onArticleClick(ArticleSimpleEntity entity) {
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

  void errorLoad() {
    BossApi.ins()
        .obtainBossArticle(widget.bossId, mCurrentType)
        .onErrorReturn([]).listen((event) {
      map[mCurrentType] = event;
      setState(() {});
    });
  }

  void onBack() {
    DataConfig.getIns().setBossTime(widget.bossId);
    Get.back();
  }

  void onShare() {
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

  void onSetting() {
    showBossSettingDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      BaseTool.toast(msg: "开启推送");
      Get.back();
    });
  }

  void onFollowChange() {
    if (bossEntity.isCollect) {
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

      BossApi.ins().obtainNoFollowBoss(widget.bossId).flatMap((value) {
        bossEntity.isCollect = false;

        return BossDbProvider.ins().delete(widget.bossId);
      }).listen((event) {
        Get.back();
        Get.back();

        setState(() {});

        BaseWidget.showDoFollowChangeDialog(context, false);

        UserEntity userEntity = Global.user.user.value;
        userEntity.traceNum--;
        Global.user.setUser(userEntity);

        Global.eventBus.fire(
          BossTackEvent(
            id: widget.bossId,
            labels: bossEntity.labels,
            isFollow: false,
          ),
        );

        JpushApi.ins().deleteTags([widget.bossId]);
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: " 取消失败，${res.msg}");
      });
    });
  }

  void doFollow() {
    BaseWidget.showLoadingAlert("尝试追踪...", context);

    BossApi.ins().obtainFollowBoss(widget.bossId).flatMap((value) {
      bossEntity.isCollect = true;

      return BossDbProvider.ins().insert(bossEntity.toSimple());
    }).listen((event) {
      Get.back();

      setState(() {});

      UserEntity userEntity = Global.user.user.value;
      userEntity.traceNum++;
      Global.user.setUser(userEntity);

      Global.eventBus.fire(
        BossTackEvent(
          id: widget.bossId,
          labels: bossEntity.labels,
          isFollow: true,
        ),
      );

      showAskPushDialog(context, onConfirm: () {
        Get.back();

        JpushApi.ins().addTags([widget.bossId]);
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
        arguments: bossEntity, transition: Transition.rightToLeftWithFade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: FutureBuilder<dynamic>(
        builder: builderWidget,
        future: builderFuture,
      ),
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return errorWidget().onClick(() {
          builderFuture = initData();
          setState(() {});
        });
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          toolbarHeight: 40,
          backgroundColor: BaseColor.pageBg,
          leading: Container(
            child: GestureDetector(
              child: Icon(Icons.arrow_back, size: 26, color: Colors.white),
              onTap: onBack,
            ),
          ),
          actions: [
            Image.asset(R.assetsImgShareWhite, width: 24, height: 24)
                .marginOn(right: 20)
                .onClick(onShare),
            Image.asset(R.assetsImgSettingWhite, width: 24, height: 24)
                .marginOn(right: 16)
                .onClick(onSetting),
          ],
          floating: false,
          pinned: true,
          snap: false,
          expandedHeight:
              MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              height: 48,
              color: BaseColor.pageBg,
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(child: tabWidget(0)),
                  Expanded(child: tabWidget(1)),
                  Expanded(child: tabWidget(2)),
                ],
              ),
            ),
          ),
          flexibleSpace: bossWidget(),
        ),
        listWidget(),
      ],
    );
  }

  Widget tabWidget(int index) {
    return Container(
      height: 48,
      child: Stack(
        children: [
          mCurrentType == (index + 1).toString()
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xfff28564),
                        Color(0xffee3b20),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  height: 8,
                ).positionOn(right: 22, left: 22, bottom: 12)
              : SizedBox(),
          Container(
            alignment: Alignment.center,
            child: Text(
              typeList[index],
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).positionOn(right: 0, left: 0, top: 12),
        ],
      ),
    ).onClick(() {
      onTabClick(index);
    });
  }

  Widget bossWidget() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: Container(
        height: MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 40 + 24,
        ),
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
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            bossInfoWidget(),
            bossInfoBottomWidget(),
          ],
        ),
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
              HttpConfig.fullUrl(bossEntity.head),
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
                  bossEntity.name,
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
                  "${bossEntity.readCount.formatCountNumber()}阅读·${bossEntity.totalCount ?? 0}篇言论·${bossEntity.collect.formatCountNumber()}关注",
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
    bool hasFollow = bossEntity.isCollect;
    Color followColor = hasFollow ? Color(0x80efefef) : Colors.red;

    return Container(
      height: 104,
      padding: EdgeInsets.only(top: 24, bottom: 16),
      margin: EdgeInsets.only(right: 16, left: 16),
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
                          bossEntity.role,
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
                  "个人简介：${bossEntity.info}",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  softWrap: true,
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16, top: 8).onClick(onWatchMore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listWidget() {
    var data = map[mCurrentType];

    return data.isNullOrEmpty()
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
                ArticleSimpleEntity entity =
                    data[index == 0 ? index : index - 1];

                return index == 0 ? noticeWidget() : articleWidget(entity);
              },
              childCount: data.length + 1,
            ),
          );
  }

  Widget noticeWidget() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
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
            "查看全部共${bossEntity.totalCount}篇",
            style: TextStyle(color: BaseColor.textDark, fontSize: 12),
          ).marginOn(left: 8),
        ],
      ),
    ).onClick(() {
      Get.to(() => BossArticlePage(), arguments: widget.bossId);
    });
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
        232;
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
    ).onClick(errorLoad);
  }

  Widget loadingWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
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
            child: MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.arrow_back, size: 26, color: Colors.white)
                            .marginOn(left: 16)
                            .onClick(onBack),
                        Expanded(child: SizedBox()),
                        Image.asset(R.assetsImgShareWhite,
                                width: 24, height: 24)
                            .marginOn(right: 20),
                        Image.asset(R.assetsImgSettingWhite,
                                width: 24, height: 24)
                            .marginOn(right: 16),
                      ],
                    ),
                  ),
                  Container(
                    height: 64,
                    margin: EdgeInsets.only(top: 24, left: 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            R.assetsImgDefaultHead,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              loadingItemWidget(0.16, 0),
                              loadingItemWidget(0.4, 0),
                            ],
                          ).marginOn(left: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 104,
                    padding: EdgeInsets.only(top: 24, bottom: 16),
                    margin: EdgeInsets.only(right: 16, left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: BaseColor.loadBg,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              loadingItemWidget(0.24, 0).marginOn(left: 16),
                              loadingItemWidget(0.64, 0)
                                  .marginOn(left: 16, top: 8),
                              loadingItemWidget(0.56, 0)
                                  .marginOn(left: 16, top: 8),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          loadingItemWidget(0.8, 16),
          loadingItemWidget(0.72, 8),
          loadingItemWidget(0.2, 8),
          loadingItemWidget(0.92, 8),
          loadingItemWidget(0.4, 16),
          loadingItemWidget(0.32, 16),
          loadingItemWidget(0.16, 16),
        ],
      ),
    );
  }

  Widget errorWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + 40 + 24 + 64 + 104,
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
            child: MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.arrow_back, size: 26, color: Colors.white)
                            .marginOn(left: 16)
                            .onClick(onBack),
                        Expanded(child: SizedBox()),
                        Image.asset(R.assetsImgShareWhite,
                                width: 24, height: 24)
                            .marginOn(right: 20),
                        Image.asset(R.assetsImgSettingWhite,
                                width: 24, height: 24)
                            .marginOn(right: 16),
                      ],
                    ),
                  ),
                  Container(
                    height: 64,
                    margin: EdgeInsets.only(top: 24, left: 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            R.assetsImgDefaultHead,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              loadingItemWidget(0.16, 0),
                              loadingItemWidget(0.4, 0),
                            ],
                          ).marginOn(left: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 104,
                    padding: EdgeInsets.only(top: 24, bottom: 16),
                    margin: EdgeInsets.only(right: 16, left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: BaseColor.loadBg,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              loadingItemWidget(0.24, 0).marginOn(left: 16),
                              loadingItemWidget(0.64, 0)
                                  .marginOn(left: 16, top: 8),
                              loadingItemWidget(0.56, 0)
                                  .marginOn(left: 16, top: 8),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    R.assetsImgErrorIcon,
                    width: 240,
                    height: 184,
                  ),
                  Text(
                    "网络异常",
                    style: TextStyle(
                        fontSize: 18,
                        color: BaseColor.textDark,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(top: 32),
                  Text(
                    "请点击屏幕重新加载或检查设备网络权限",
                    style: TextStyle(fontSize: 16, color: BaseColor.textGray),
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
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
