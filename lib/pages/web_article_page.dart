import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/db/boss_db_provider.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/boss_tack_event.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/pages/login_phone_wechat.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebArticlePage extends StatefulWidget {
  String articleId = Get.arguments as String;
  var articleUrl = HttpConfig.globalEnv.baseUrl;

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
  }

  void doArticleDetail() {
    BossApi.ins().obtainArticleDetail(widget.articleId).listen((event) {
      topKey.currentState.bossId = event.bossId;
      topKey.currentState.bossHead = event.bossVO.head;
      topKey.currentState.bossName = event.bossVO.name;
      topKey.currentState.bossRole = event.bossVO.role;
      topKey.currentState.hasTack = event.bossVO.isCollect;
      topKey.currentState.bossEntity = event.bossVO;

      bottomKey.currentState.hasCollect = event.isCollect;
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
    String url = "${widget.articleUrl}#/article?id=${widget.articleId}";
    print(url);
    return WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (s) {
        print('onPageFinished:$s');
      },
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
      BaseWidget.showLoadingAlert("尝试取消...", context);

      BossApi.ins().obtainNoFollowBoss(bossId).flatMap((value) {
        hasTack = false;

        return BossDbProvider.ins().delete(bossId);
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
            id: bossId,
            labels: bossEntity.labels,
            isFollow: false,
          ),
        );

        JpushApi.ins().deleteTags([bossId]);
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: " 取消失败，${res.msg}");
      });
    });
  }

  void doFollow() {
    BaseWidget.showLoadingAlert("尝试追踪...", context);

    BossApi.ins().obtainFollowBoss(bossId).flatMap((value) {
      hasTack = true;

      return BossDbProvider.ins().insert(bossEntity.toSimple());
    }).listen((event) {
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
      BaseTool.toast(msg: " 追踪失败，${res.msg}");
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
                          hasTack ? "已追踪" : "追踪",
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
  String articleUrl;
  String articleTitle;
  String articleDes;
  String articleCover;
  bool hasCollect = false; //文章收藏

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
    showShareDialog(context, onDismiss: () {
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

  ///阅读文章
  void doReadArticle() {
    UserApi.ins().obtainReadArticle(widget.articleId).listen((event) {
      BaseTool.doAddRead();
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
      Get.to(() => LoginPhoneWechatPage());
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
        tryFavoriteArticle(widget.articleId, folderId);
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
      return UserApi.ins().obtainFavoriteArticle(widget.articleId, value.id);
    }).listen((event) {
      Get.back();
      Get.back();
      Get.back();

      hasCollect = true;

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

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

      UserEntity user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

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

    UserApi.ins().obtainCancelFavoriteArticle(widget.articleId).listen((event) {
      Get.back();

      hasCollect = false;

      UserEntity user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

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
    return Container(
      height: 48 + MediaQuery.of(context).padding.bottom,
      color: BaseColor.loadBg,
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
                  hasCollect
                      ? R.assetsImgFavoriteAccent
                      : R.assetsImgFavoriteDark,
                  width: 22,
                  height: 22,
                ),
                Text(
                  hasCollect ? "已收藏" : "收藏",
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
                  "分享",
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
