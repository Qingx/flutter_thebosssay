import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/boss_tack_event.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/event/refresh_point_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/pages/login_phone_wechat.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebArticlePage extends StatefulWidget {
  String articleId = Get.arguments as String;

  var articleUrl = HttpConfig.globalEnv.baseUrl;

  // var articleUrl = "http://192.168.1.85:9531";

  bool fromBoss = false;

  WebArticlePage({Key key, this.fromBoss}) : super(key: key);

  @override
  _WebArticlePageState createState() => _WebArticlePageState();
}

class _WebArticlePageState extends State<WebArticlePage> {
  GlobalKey<_TopBarWidgetState> topKey = GlobalKey();
  GlobalKey<_BottomBarWidgetState> bottomKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();

    TalkingApi.ins().obtainPageEnd(TalkingApi.Article);
  }

  @override
  void initState() {
    super.initState();

    doArticleDetail();

    TalkingApi.ins().obtainPageStart(TalkingApi.Article);

    FlutterAppBadger.removeBadge(); //????????????
  }

  void doArticleDetail() {
    AppApi.ins().obtainGetArticleDetail(widget.articleId).listen((event) {
      topKey.currentState.bossId = event.bossId;
      topKey.currentState.bossHead = event.bossVO.head;
      topKey.currentState.bossName = event.bossVO.name;
      topKey.currentState.bossRole = event.bossVO.role;
      topKey.currentState.hasTack = event.bossVO.isCollect;
      topKey.currentState.bossEntity = event.bossVO;

      bottomKey.currentState.bossName = event.bossVO.name;
      bottomKey.currentState.hasCollect = event.isCollect;
      bottomKey.currentState.hasPoint = event.isPoint;
      bottomKey.currentState.collectNum = event.collect;
      bottomKey.currentState.pointNum = event.point;
      bottomKey.currentState.articleTitle = event.title;
      bottomKey.currentState.articleDes = event.descContent ?? "";

      if (!event.files.isNullOrEmpty()) {
        bottomKey.currentState.articleCover = event.files[0];
      }

      topKey.currentState.setState(() {});
      bottomKey.currentState.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            TopBarWidget(
              widget.articleId,
              widget.fromBoss,
              key: topKey,
            ),
            Expanded(
              child: webWidget(),
            ),
            BottomBarWidget(
              widget.articleId,
              key: bottomKey,
            ),
          ],
        ),
      ),
    );
  }

  Widget webWidget() {
    var user = Global.user.user.value;

    String url =
        "${widget.articleUrl}#/article?id=${widget.articleId}&version=${user.version}";
    return WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (s) {
        print('onPageFinished:$s');
      },
      javascriptChannels: [
        JavascriptChannel(
            name: "RecommendArticle",
            onMessageReceived: (JavascriptMessage message) {
              String articleId = message.message;
              print("JavascriptMessage:$articleId");

              if (!articleId.isNullOrEmpty()) {
                Get.off(
                  () => WebArticlePage(
                    fromBoss: widget.fromBoss,
                  ),
                  preventDuplicates: false,
                  arguments: articleId,
                );
              }
            }),
        JavascriptChannel(
            name: "JumpArticle",
            onMessageReceived: (JavascriptMessage message) {
              String url = message.message;
              print("JavascriptMessage:$url");

              launch(url);
            }),
      ].toSet(),
    );
  }
}

class TopBarWidget extends StatefulWidget {
  String articleId;
  bool fromBoss;

  TopBarWidget(this.articleId, this.fromBoss, {Key key}) : super(key: key);

  @override
  _TopBarWidgetState createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  bool hasTack = false;
  String bossId;
  String bossHead;
  String bossName;
  String bossRole;

  BossInfoEntity bossEntity;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    bossId = "";
    bossHead = "";
    bossName = "";
    bossRole = "";
  }

  void onFollowChange() {
    if (hasTack) {
      cancelFollow();
    } else {
      doFollow();
    }
  }

  void cancelFollow() {
    showFollowAskCancelDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      BaseWidget.showLoadingAlert("????????????...", context);

      AppApi.ins().obtainCancelFollowBoss(bossId).listen((event) {
        hasTack = false;
        CacheProvider.getIns().deleteBoss(bossId);
        Get.back();
        Get.back();

        setState(() {});

        BaseWidget.showDoFollowChangeDialog(context, false);

        UserEntity userEntity = Global.user.user.value;
        userEntity.traceNum--;
        Global.user.setUser(userEntity);

        Global.eventBus.fire(
          BossTackEvent(
            id: bossId,
            labels: bossEntity.labels,
            isFollow: false,
          ),
        );

        JpushApi.ins().deleteTags([bossId]);
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: " ???????????????${res.msg}");
      });
    });
  }

  void doFollow() {
    BaseWidget.showLoadingAlert("????????????...", context);

    AppApi.ins().obtainFollowBoss(bossId).listen((event) {
      hasTack = true;
      bossEntity.isCollect = true;
      CacheProvider.getIns().insertBoss(bossEntity.toSimple());

      Get.back();

      setState(() {});

      UserEntity userEntity = Global.user.user.value;
      userEntity.traceNum++;
      Global.user.setUser(userEntity);

      Global.eventBus.fire(
        BossTackEvent(
          id: bossId,
          labels: bossEntity.labels,
          isFollow: true,
        ),
      );

      showAskPushDialog(context, onConfirm: () {
        Get.back();

        JpushApi.ins().addTags([bossId]);
        BaseWidget.showDoFollowChangeDialog(context, true);
      }, onDismiss: () {
        Get.back();

        BaseWidget.showDoFollowChangeDialog(context, true);
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: " ???????????????${res.msg}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.only(left: 12, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: BaseColor.textDark,
            size: 28,
          ).onClick(() {
            Get.back();
          }),
          Expanded(
            child: bossName.isNullOrEmpty()
                ? SizedBox()
                : Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        margin: EdgeInsets.only(left: 16, right: 8),
                        child: ClipOval(
                          child: Image.network(
                            HttpConfig.fullUrl(bossHead),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                R.assetsImgDefaultHead,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              bossName,
                              style: TextStyle(
                                color: BaseColor.textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              bossRole,
                              style: TextStyle(
                                color: BaseColor.textGray,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 28,
                        margin: EdgeInsets.only(left: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          color: hasTack ? BaseColor.loadBg : BaseColor.accent,
                        ),
                        child: Text(
                          hasTack ? "?????????" : "??????",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                          softWrap: false,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).onClick(onFollowChange),
                    ],
                  ).onClick(() {
                    if (widget.fromBoss) {
                      Get.back();
                    } else {
                      Get.to(() => BossHomePage(), arguments: bossEntity.id);
                    }
                  }),
          ),
        ],
      ),
    );
  }
}

class BottomBarWidget extends StatefulWidget {
  String articleId;

  BottomBarWidget(this.articleId, {Key key}) : super(key: key);

  @override
  _BottomBarWidgetState createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends State<BottomBarWidget> {
  String bossName;
  String articleUrl;
  String articleTitle;
  String articleDes;
  String articleCover;
  bool hasCollect = false; //????????????
  bool hasPoint = false; //????????????
  int collectNum = 0; //?????????
  int pointNum = 0; //?????????

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    articleUrl =
        "${HttpConfig.globalEnv.baseUrl}#/article?id=${widget.articleId}";

    doReadArticle();
  }

  void doOnShare() {
    showShareDialog(context, false, onDismiss: () {
      Get.back();
    }, doClick: (index) {
      switch (index) {
        case 0:
          BaseTool.shareToSession(
            mUrl: "$articleUrl&type=1",
            mTitle: articleTitle,
            mDes: articleDes,
            thumbnail: articleCover,
          );
          break;
        case 1:
          BaseTool.shareToTimeline(
            mUrl: "$articleUrl&type=1",
            mTitle: articleTitle,
            mDes: articleDes,
            thumbnail: articleCover,
          );
          break;
        default:
          BaseTool.shareCopyLink(mUrl: "$articleUrl&type=1");
          break;
      }
    });
  }

  ///????????????
  void doReadArticle() {
    AppApi.ins().obtainReadArticle(widget.articleId).listen((event) {
      BaseTool.doAddRead();
    });
  }

  void onPointChange() {
    if (UserConfig.getIns().loginStatus) {
      if (hasPoint) {
        cancelPoint();
      } else {
        doPoint();
      }
    } else {
      BaseTool.toast(msg: "???????????????");
      BaseTool.jumpLogin(context);
    }
  }

  void doPoint() {
    hasPoint = true;
    pointNum++;
    setState(() {});

    AppApi.ins().obtainDoPoint(widget.articleId).listen((event) {
      var user = Global.user.user.value;
      user.pointNum++;
      Global.user.setUser(user);

      Global.eventBus.fire(RefreshPointEvent(widget.articleId, true));
    });
  }

  void cancelPoint() {
    hasPoint = false;
    pointNum--;
    setState(() {});

    AppApi.ins().obtainCancelPoint(widget.articleId).listen((event) {
      var user = Global.user.user.value;
      user.pointNum--;
      Global.user.setUser(user);

      Global.eventBus.fire(RefreshPointEvent(widget.articleId, false));
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
      BaseTool.toast(msg: "???????????????");
      BaseTool.jumpLogin(context);
    }
  }

  ///???????????????
  void showFavoriteFolder() {
    BaseWidget.showLoadingAlert("???????????????...", context);
    AppApi.ins().obtainCollectFolder().listen((event) {
      Get.back();

      showSelectFolderDialog(context, event, onDismiss: () {
        Get.back();
      }, onConfirm: (folderId) {
        tryFavoriteArticle(widget.articleId, folderId);
      }, onCreate: () {
        showAddFolder();
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "???????????????${res.msg}");
    });
  }

  ///???????????????
  void showAddFolder() {
    showNewFolderDialog(
      context,
      onDismiss: () {
        Get.back();
      },
      onConfirm: onAddFolder,
    );
  }

  ///????????????????????????
  void onAddFolder(name) {
    BaseWidget.showLoadingAlert("????????????...", context);
    AppApi.ins().obtainCreateFavorite(name).flatMap((value) {
      return AppApi.ins().obtainCollectArticle(widget.articleId, value.id);
    }).listen((event) {
      Get.back();
      Get.back();
      Get.back();

      hasCollect = true;
      collectNum++;

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      Global.eventBus
          .fire(RefreshCollectEvent(fromFolder: false, doCollect: true));
      setState(() {});

      BaseTool.toast(msg: "????????????");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "???????????????${res.msg}");
    });
  }

  ///??????????????????
  void tryFavoriteArticle(String articleId, String folderId) {
    BaseWidget.showLoadingAlert("????????????...", context);
    AppApi.ins().obtainCollectArticle(articleId, folderId).listen((event) {
      Get.back();
      Get.back();

      hasCollect = true;
      collectNum++;

      UserEntity user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      Global.eventBus
          .fire(RefreshCollectEvent(fromFolder: false, doCollect: true));
      setState(() {});

      BaseTool.toast(msg: "????????????");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "???????????????${res.msg}");
    });
  }

  ///????????????????????????
  void tryCancelFavoriteArticle() {
    BaseWidget.showLoadingAlert("????????????...", context);

    AppApi.ins().obtainCancelCollectArticle(widget.articleId).listen((event) {
      Get.back();

      hasCollect = false;
      collectNum--;

      UserEntity user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      Global.eventBus.fire(RefreshCollectEvent(
          fromFolder: false, doCollect: false, articleId: widget.articleId));
      setState(() {});

      BaseTool.toast(msg: "????????????");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "???????????????${res.msg}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            margin: EdgeInsets.only(right: 24),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  hasPoint ? R.assetsImgPointAccent : R.assetsImgPointDark,
                  width: 22,
                  height: 22,
                ),
                Text(
                  pointNum.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: hasCollect ? BaseColor.accent : BaseColor.textDark,
                  ),
                ),
              ],
            ),
          ).onClick(onPointChange),
          Container(
            width: 32,
            margin: EdgeInsets.only(right: 24),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  hasCollect
                      ? R.assetsImgFavoriteAccent
                      : R.assetsImgFavoriteDark,
                  width: 22,
                  height: 22,
                ),
                Text(
                  collectNum.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: hasCollect ? BaseColor.accent : BaseColor.textDark,
                  ),
                ),
              ],
            ),
          ).onClick(onFavoriteChange),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  R.assetsImgShareDark,
                  width: 22,
                  height: 22,
                ),
                Text(
                  "??????",
                  style: TextStyle(
                    fontSize: 10,
                    color: BaseColor.textDark,
                  ),
                ),
              ],
            ),
          ).onClick(doOnShare),
        ],
      ),
    );
  }
}
