import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/new%20_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/event/refresh_user_event.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import 'input_phone_page.dart';

class ArticlePage extends StatefulWidget {
  ArticleEntity entity;

  ArticlePage({Key key, this.entity}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with WidgetsBindingObserver {
  ScrollController scrollController;

  Map<String, dynamic> map;
  ArticleEntity mData;
  String articleId;
  bool hasCollect = false;

  var builderFuture;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    map = Get.arguments as Map<String, dynamic>;
    articleId = map["articleId"];

    builderFuture = loadInitData();

    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      doReadArticle();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    scrollController?.dispose();
  }

  ///初始化数据
  Future<ArticleEntity> loadInitData() {
    if (widget.entity == null) {
      return BossApi.ins().obtainArticleDetail(articleId).doOnData((event) {
        mData = event;
        hasCollect = mData.isCollect;

        setState(() {});
      }).last;
    } else {
      return Observable<ArticleEntity>.just(widget.entity).doOnData((event) {
        mData = event;
        hasCollect = mData.isCollect;
        setState(() {});
      }).last;
    }
  }

  ///阅读文章
  void doReadArticle() {
    UserApi.ins().obtainReadArticle(articleId).listen((event) {
      UserEntity user = Global.user.user.value;
      user.readNum++;
      Global.user.setUser(user);
      UserConfig.getIns().user = user;
    });
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

  void onFavoriteChange() {
    if (UserConfig.getIns().loginStatus) {
      if (hasCollect) {
        tryCancelFavoriteArticle();
      } else {
        showFavoriteFolder();
      }
    } else {
      BaseTool.toast(msg: "请先登录！");
      Get.to(() => InputPhonePage());
    }
  }

  ///展示收藏夹
  void showFavoriteFolder() {
    BaseWidget.showLoadingAlert("获取收藏夹...", context);
    UserApi.ins().obtainFavoriteList().listen((event) {
      Get.back();

      showSelectFolderDialog(context, event, onDismiss: () {
        Get.back();
      }, onConfirm: (folderId) {
        tryFavoriteArticle(mData.id, folderId);
      }, onCreate: () {
        showAddFolder();
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "获取失败，${res.msg}");
    });
  }

  ///添加收藏夹
  void showAddFolder() {
    showNewFolderDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: onAddFolder);
  }

  ///添加到新建收藏夹
  void onAddFolder(name) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);
    UserApi.ins().obtainCreateFavorite(name).flatMap((value) {
      return UserApi.ins().obtainFavoriteArticle(mData.id, value.id);
    }).listen((event) {
      Get.back();
      Get.back();
      Get.back();

      hasCollect = true;
      mData.isCollect = true;
      Global.eventBus.fire(BaseEvent(RefreshUserEvent));
      Global.eventBus.fire(BaseEvent(RefreshCollectEvent));
      setState(() {});

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败，${res.msg}");
    });
  }

  ///尝试收藏文章
  void tryFavoriteArticle(String articleId, String folderId) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);
    UserApi.ins().obtainFavoriteArticle(articleId, folderId).listen((event) {
      Get.back();
      Get.back();

      hasCollect = true;
      mData.isCollect = true;
      Global.eventBus.fire(BaseEvent(RefreshUserEvent));
      Global.eventBus.fire(BaseEvent(RefreshCollectEvent));
      setState(() {});

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败，${res.msg}");
    });
  }

  ///尝试取消收藏文章
  void tryCancelFavoriteArticle() {
    BaseWidget.showLoadingAlert("取消收藏...", context);

    UserApi.ins().obtainCancelFavoriteArticle(mData.id).listen((event) {
      Get.back();

      hasCollect = false;
      mData.isCollect = false;
      Global.eventBus.fire(BaseEvent(RefreshUserEvent));
      Global.eventBus.fire(BaseEvent(RefreshCollectEvent));
      setState(() {});

      BaseTool.toast(msg: "取消成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "取消失败，${res.msg}");
    });
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
              color: BaseColor.loadBg,
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              color: BaseColor.loadBg,
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(child: SizedBox()),
                  Image.asset(
                          hasCollect
                              ? R.assetsImgFavoriteAccent
                              : R.assetsImgFavoriteDark,
                          width: 24,
                          height: 24)
                      .marginOn(right: 20)
                      .onClick(onFavoriteChange),
                  Image.asset(R.assetsImgShareDark, width: 24, height: 24)
                      .marginOn(right: 16)
                      .onClick(onShare),
                ],
              ),
            ),
            Expanded(
              child: futureWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget futureWidget() {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<ArticleEntity> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                contentWidget()
                    .positionOn(top: 0, bottom: 0, left: 0, right: 0),
                floatWidget().positionOn(
                    bottom: MediaQuery.of(context).padding.bottom + 64,
                    right: 16),
              ],
            );
          } else
            return BaseWidget.errorWidget(() {
              loadInitData();
              setState(() {});
            });
        } else {
          return BaseWidget.loadingWidget();
        }
      },
      future: builderFuture,
    );
  }

  Widget contentWidget() {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: ListView(
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        controller: scrollController,
        children: [
          Text(
            mData.title,
            style: TextStyle(
              fontSize: 18,
              color: BaseColor.textDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${mData.collect}k收藏·${mData.point}w浏览",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(child: SizedBox()),
                Icon(
                  Icons.access_time,
                  color: BaseColor.textGray,
                  size: 14,
                ).marginOn(right: 4),
                Text(
                  BaseTool.getUpdateTime(mData.createTime)
                      .replaceAll(RegExp(r'更新'), ""),
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          bossWidget(),
          bodyWidget(),
        ],
      ),
    );
  }

  Widget bossWidget() {
    return Container(
      height: 64,
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              HttpConfig.fullUrl(mData.bossVO.head),
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  R.assetsImgTestPhoto,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12, right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        mData.bossVO.name,
                        style: TextStyle(
                            color: BaseColor.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        softWrap: false,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Image.asset(
                        R.assetsImgBossLabel,
                        width: 56,
                        height: 16,
                      ).marginOn(left: 8)
                    ],
                  ),
                  Text(
                    mData.bossVO.role,
                    style: TextStyle(
                      color: BaseColor.textGray,
                      fontSize: 10,
                    ),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyWidget() {
    String document = mData.content;
    return Container(
      child: Html(
        data: document,
        style: {
          "body": Style(
            fontSize: FontSize(17),
            // lineHeight: 30,
            letterSpacing: 1,
            color: BaseColor.textDarkLight,
            textAlign: TextAlign.start,
          ),
        },
      ),
    );
  }

  Widget floatWidget() {
    return Container(
      alignment: Alignment.center,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: BaseColor.line,
              offset: Offset(0.0, 4.0), //阴影x,y轴偏移量
              blurRadius: 4, //阴影模糊程度
              spreadRadius: 0 //阴影扩散程度
              )
        ],
      ),
      child: Icon(
        Icons.keyboard_arrow_up,
        color: BaseColor.textDark,
        size: 24,
      ),
    ).onClick(() {
      scrollController.position
          .moveTo(scrollController.position.minScrollExtent);
    });
  }
}
