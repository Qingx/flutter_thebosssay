import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/pages/login_phone_wechat.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebArticlePage extends StatelessWidget {
  String articleId = Get.arguments as String;
  var articleUrl = HttpConfig.globalEnv.baseUrl;
  // var articleUrl = "http://192.168.1.85:9529";

  WebArticlePage({Key key}) : super(key: key);

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
            TopBarWidget(articleId),
            Expanded(
              child: webWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget webWidget() {
    String url = "$articleUrl#/article?id=$articleId";
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

  TopBarWidget(this.articleId, {Key key}) : super(key: key);

  @override
  _TopBarWidgetState createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  String articleUrl;
  String articleTitle;
  String articleDes;
  String articleCover;
  bool hasCollect = false;

  @override
  void dispose() {
    super.dispose();

    TalkingApi.ins().obtainPageEnd("WebArticlePage");
  }

  @override
  void initState() {
    super.initState();

    articleUrl =
        "${HttpConfig.globalEnv.baseUrl}#/article?id=${widget.articleId}";

    doReadArticle();
    doArticleDetail();

    TalkingApi.ins().obtainPageStart("WebArticlePage");
  }

  void doArticleDetail() {
    BossApi.ins().obtainArticleDetail(widget.articleId).listen((event) {
      hasCollect = event.isCollect;
      articleTitle = event.title;
      articleDes = event.descContent ?? "";

      if (!event.files.isNullOrEmpty()) {
        articleCover = event.files[0];
      }

      setState(() {});
    });
  }

  void doOnShare() {
    showShareDialog(context, onDismiss: () {
      Get.back();
    }, doClick: (index) {
      switch (index) {
        case 0:
          BaseTool.shareToSession(
            mUrl: articleUrl,
            mTitle: articleTitle,
            mDes: articleDes,
            thumbnail: articleCover,
          );
          break;
        case 1:
          BaseTool.shareToTimeline(
            mUrl: articleUrl,
            mTitle: articleTitle,
            mDes: articleDes,
            thumbnail: articleCover,
          );
          break;
        default:
          BaseTool.shareCopyLink(mUrl: articleUrl);
          break;
      }
    });
  }

  ///阅读文章
  void doReadArticle() {
    UserApi.ins().obtainReadArticle(widget.articleId).listen((event) {
      UserEntity user = Global.user.user.value;
      user.readNum++;
      Global.user.setUser(user);
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
              .onClick(doOnShare),
        ],
      ),
    );
  }
}