import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/scheme_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/ask_notifi_dialog.dart';
import 'package:flutter_boss_says/dialog/daily_dialog.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/dialog/version_update_dialog.dart';
import 'package:flutter_boss_says/event/jpush_article_event.dart';
import 'package:flutter_boss_says/event/jump_boss_event.dart';
import 'package:flutter_boss_says/event/page_scroll_event.dart';
import 'package:flutter_boss_says/pages/daily_poster_page.dart';
import 'package:flutter_boss_says/pages/home_boss_content_page.dart';
import 'package:flutter_boss_says/pages/home_mine_page.dart';
import 'package:flutter_boss_says/pages/home_speech_page.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:notification_permissions/notification_permissions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int mCurrentIndex;
  List<String> mTitles;
  List<List<String>> mIcons;
  List<Widget> mPages;

  PageController mPageController;
  StreamSubscription<BaseEvent> eventDispose;

  @override
  void dispose() {
    super.dispose();

    mPageController?.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    mCurrentIndex = 0;
    mTitles = ["言论", "老板", "我的", "回顶部"];
    mIcons = [
      [R.assetsImgTalkNormal, R.assetsImgScrollTop],
      [R.assetsImgBossNormal, R.assetsImgBossSelect],
      [R.assetsImgMineNormal, R.assetsImgMineSelect]
    ];
    mPages = [HomeSpeechPage(), HomeBossContentPage(), HomeMinePage()];

    mPageController = PageController();

    eventBus();

    doCheckUpdate();

    doCheckNotifi();

    doJPushCall();

    doTalkingData();

    doAppScheme();

    doDailyTalk();

    doShangjia();

    JpushApi.ins().doPreLogin();
  }

  ///获取上架状态
  void doShangjia() {
    UserApi.ins().obtainCheckShangjia().onErrorReturn(false).listen((event) {
      DataConfig.getIns().isCheckFinish = event;
    });
  }

  ///AppScheme
  void doAppScheme() {
    SchemeApi.ins().doAppScheme();
  }

  ///检测通知权限
  void doCheckNotifi() {
    NotificationPermissions.getNotificationPermissionStatus().then((value) {
      if (value != PermissionStatus.granted) {
        int lastTime = DataConfig.getIns().notifiTime;
        if (lastTime == -1 || !BaseTool.isSameDay(lastTime)) {
          DataConfig.getIns().notifiTime =
              DateTime.now().millisecondsSinceEpoch;

          showAskNotifiDialog(context, onDismiss: () {
            Get.back();
          }, onConfirm: () {
            AppSettings.openAppSettings();
            Get.back();
          });
        }
      }
    });
  }

  void doJPushCall() {
    FlutterAppBadger.removeBadge(); //删除红点

    ///冷启动 通知跳转
    JpushApi.ins().jPush.getLaunchAppNotification().then((value) {
      var lastId = DataConfig.getIns().notID;
      var current = value["extras"]["articleId"];
      if (current != null && lastId != current) {
        DataConfig.getIns().notID = current;

        Get.to(() => WebArticlePage(fromBoss: false),
            arguments: value["extras"]["articleId"]);
      }
    });

    ///极光推送回调
    JpushApi.ins().jPush.addEventHandler(
      onReceiveMessage: (msg) async {
        //消息回调
        print('message:$msg');
        Global.hint.setHint(msg["content"]);
      },
      onReceiveNotification: (msg) async {
        //通知回调
        print('notification:$msg');

        if (msg["extras"]["articleId"] != null) {
          String bossId = msg["extras"]["bossId"];
          String updateTime = msg["extras"]["updateTime"];
          print('notification:$bossId');
          print('notification:$updateTime');

          Global.eventBus.fire(JpushArticleEvent(
              bossId: bossId, updateTime: int.parse(updateTime)));
        }
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        //点击通知
        print("onOpenNotification:$message");

        if (message["extras"]["articleId"] != null) {
          Get.to(() => WebArticlePage(fromBoss: false),
              arguments: message["extras"]["articleId"]);
        }
      },
    );
  }

  void doTalkingData() async {
    TalkingApi.ins().obtainDeviceId().listen((event) {
      print('TalkingData:deviceId：$event');
    });
  }

  void doCheckUpdate() {
    UserApi.ins().obtainCheckUpdate().listen((event) {
      showVersionUpdate(context, onDismiss: () {
        Get.back();
      }, onConfirm: () {
        SchemeApi.ins().jumpAppStore();
        Get.back();
      });
    });
  }

  ///eventBus
  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == JumpBossEvent) {
        jumpToBoss();
      }
    });
  }

  void jumpToBoss() {
    mPageController.animateToPage(
      1,
      duration: Duration(milliseconds: 240),
      curve: Curves.easeInOutExpo,
    );
  }

  ///每日一言
  void doDailyTalk() {
    var lastTime = UserConfig.getIns().lastDailyTime;
    if (UserConfig.getIns().loginStatus) {
      if (!BaseTool.isSameDay(lastTime) || lastTime == -1) {
        AppApi.ins().obtainGetDaily().listen((event) {
          UserConfig.getIns().setLastDailyTime =
              DateTime.now().millisecondsSinceEpoch;

          showDailyDialog(
            context,
            event,
            doPoint: (state) {
              doPointDaily(event, state);
            },
            doFavorite: (state) {
              doFavoriteDaily(event, state);
            },
            doShare: () {
              doShare(event);
            },
          );
        });
      }
    }
  }

  ///分享
  void doShare(DailyEntity event) {
    showShareDialog(context, true, onDismiss: () {
      Get.back();
    }, doClick: (index) {
      switch (index) {
        case 0:
          BaseTool.shareToSession(
            mDes: event.content,
            mTitle: "分享一段${event.bossName}的语录，深有感触",
            thumbnail: HttpConfig.fullUrl(event.bossHead),
          );
          break;
        case 1:
          BaseTool.shareToTimeline(
            mDes: event.content,
            mTitle: "分享一段${event.bossName}的语录，深有感触",
            thumbnail: HttpConfig.fullUrl(event.bossHead),
          );
          break;
        case 2:
          BaseTool.shareCopyLink();
          break;
        case 3:
          Get.to(() => DailyPosterPage(event), preventDuplicates: false);
          break;
      }
    });
  }

  ///每日一言点赞
  void doPointDaily(DailyEntity entity, Function state) {
    var status = !entity.isPoint;
    AppApi.ins().obtainPointDaily(entity.id, status).listen((event) {
      entity.isPoint = status;
      state();

      var user = Global.user.user.value;
      if (status) {
        user.pointNum++;
      } else {
        user.pointNum--;
      }

      Global.user.setUser(user);
    }, onError: (res) {
      print(res.msg);
      BaseTool.toast(msg: "${status ? "点赞失败" : "取消失败"}");
    });
  }

  ///每日一言收藏
  void doFavoriteDaily(DailyEntity entity, Function state) {
    if (UserConfig.getIns().loginStatus) {
      if (entity.isCollect) {
        doNoFavorite(entity, state);
      } else {
        showFavoriteFolder(entity, state);
      }
    } else {
      BaseTool.toast(msg: "请先登录！");
      BaseTool.jumpLogin(context);
    }
  }

  ///每日一言取消收藏
  void doNoFavorite(DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试取消收藏...", context);
    AppApi.ins().obtainCancelCollectDaily(entity.id).listen((event) {
      Get.back();

      var user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      entity.isCollect = false;
      state();

      BaseTool.toast(msg: "取消成功");
    });
  }

  ///展示收藏夹
  void showFavoriteFolder(DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("获取收藏夹...", context);
    AppApi.ins().obtainCollectFolder().listen((event) {
      Get.back();

      showSelectFolderDialog(context, event, onDismiss: () {
        Get.back();
      }, onConfirm: (folderId) {
        doAddFavorite(folderId, entity, state);
      }, onCreate: () {
        showAddFolder(entity, state);
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "获取失败");
    });
  }

  ///展示创建收藏夹
  void showAddFolder(DailyEntity entity, Function state) {
    showNewFolderDialog(
      context,
      onDismiss: () {
        Get.back();
      },
      onConfirm: (name) {
        doAddFolder(name, entity, state);
      },
    );
  }

  ///添加到新建收藏夹
  void doAddFolder(String name, DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);
    AppApi.ins().obtainCreateFavorite(name).flatMap((value) {
      return AppApi.ins().obtainCollectDaily(entity.id, value.id);
    }).listen((event) {
      Get.back();
      Get.back();
      Get.back();

      entity.isCollect = true;
      state();

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败");
    });
  }

  ///每日一言收藏
  void doAddFavorite(String folderId, DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);

    AppApi.ins().obtainCollectDaily(entity.id, folderId).listen((event) {
      Get.back();
      Get.back();

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      entity.isCollect = true;
      state();

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败，${res.msg}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: pageWidget(),
      bottomNavigationBar: bottomWidget(),
    );
  }

  Widget pageWidget() {
    return PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (int) {
          mCurrentIndex = int;
          setState(() {});
        },
        controller: mPageController,
        itemCount: mPages.length,
        itemBuilder: (context, index) {
          return mPages[index];
        });
  }

  Widget bottomWidget() {
    return Container(
      color: Colors.white,
      alignment: Alignment.topCenter,
      height: 50 + MediaQuery.of(context).padding.bottom,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: bottomItemWidget(0)),
          Expanded(child: bottomItemWidget(1)),
          Expanded(child: bottomItemWidget(2)),
        ],
      ),
    );
  }

  Widget bottomItemWidget(int index) {
    Color mCurrentColor =
        mCurrentIndex == index ? BaseColor.accent : BaseColor.textGray;
    String mCurrentIcon = mIcons[index][mCurrentIndex == index ? 1 : 0];
    String mCurrentName =
        mCurrentIndex == index && index == 0 ? mTitles[3] : mTitles[index];
    return Container(
      height: 50,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          itemLabelWidget(index),
          itemIconWidget(mCurrentIcon),
          Text(
            mCurrentName,
            style: TextStyle(fontSize: 12, color: mCurrentColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).onClick(() {
      if (mCurrentIndex != index) {
        mCurrentIndex = index;
        mPageController.jumpToPage(mCurrentIndex);
        setState(() {});
      } else {
        if (index != 2) {
          Global.eventBus.fire(PageScrollEvent());
        }
      }
    });
  }

  Widget itemLabelWidget(int index) {
    return Container(
      width: 36,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
        color: mCurrentIndex == index ? BaseColor.accent : Colors.white,
      ),
    );
  }

  Widget itemIconWidget(String icon) {
    return Image.asset(
      icon,
      width: 24,
      height: 24,
    );
  }
}
