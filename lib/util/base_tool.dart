import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/pages/login_phone_wechat.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class BaseTool {
  static void jumpLogin(BuildContext context) {
    if (DataConfig.getIns().isCheckFinish) {
      JpushApi.ins().doLogin(context);
    } else {
      Get.to(() => LoginPhoneWechatPage());
    }
  }

  static final TwentyYears = 60 * 60 * 24 * 1000 * 365 * 20;

  static bool eq(double num1, double num2) {
    return (num1 - num2).abs() <= 0.000005;
  }

  static void toast({String msg}) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }

  static void jverifyToast({String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.white,
      textColor: BaseColor.textDark,
    );
  }

  static final _uuid = Uuid();

  static String createTempId() {
    String uuid = _uuid.v4().replaceAll(RegExp(r'-'), "");
    return "temp$uuid";
  }

  static String getSquareTime(int startTime) {
    int endTime = DateTime.now().millisecondsSinceEpoch;
    if (endTime >= startTime) {
      int diff = endTime - startTime;

      int days = diff ~/ (1000 * 60 * 60 * 24);
      int hours = diff ~/ (1000 * 60 * 60);
      int minutes = diff ~/ (1000 * 60);
      int seconds = diff ~/ 1000;

      if (days > 2) {
        return "3天前更新";
      } else if (days > 1) {
        return "2天前更新";
      } else if (days > 0) {
        return "昨日更新";
      } else if (hours > 0) {
        return "$hours小时前更新";
      } else if (minutes > 0) {
        return "$minutes分钟前更新";
      } else {
        return "$seconds秒前更新";
      }
    } else {
      return "刚刚";
    }
  }

  static String getArticleItemTime(int startTime) {
    int endTime = DateTime.now().millisecondsSinceEpoch;
    if (endTime >= startTime) {
      int diff = endTime - startTime;

      int days = diff ~/ (1000 * 60 * 60 * 24);
      int hours = diff ~/ (1000 * 60 * 60);
      int minutes = diff ~/ (1000 * 60);
      int seconds = diff ~/ 1000;

      if (days > 0) {
        return DateFormat.getYYMMDD(startTime);
      } else if (hours > 0) {
        return "$hours小时前更新";
      } else if (minutes > 0) {
        return "$minutes分钟前更新";
      } else {
        return "$seconds秒前更新";
      }
    } else {
      return "刚刚";
    }
  }

  ///是否符合最近更新条件 30天
  static bool isLatest(int startTime) {
    int endTime = DateTime.now().millisecondsSinceEpoch;
    if (endTime >= startTime) {
      int diff = endTime - startTime;
      int days = diff ~/ (1000 * 60 * 60 * 24);

      return days <= 30;
    } else {
      return false;
    }
  }

  ///获取boss最近更新文章时间
  static String getBossItemTime(int startTime) {
    int endTime = DateTime.now().millisecondsSinceEpoch;

    if (endTime >= startTime) {
      int diff = endTime - startTime;

      int days = diff ~/ (1000 * 60 * 60 * 24);
      int hours = diff ~/ (1000 * 60 * 60);
      int minutes = diff ~/ (1000 * 60);
      int seconds = diff ~/ 1000;

      if (days > 0) {
        return "$days天前更新";
      } else if (hours > 0) {
        return "最近$hours小时更新";
      } else if (minutes > 0) {
        return "$minutes分钟前更新";
      } else {
        return "$seconds秒前更新";
      }
    } else {
      return "刚刚";
    }
  }

  static Future<bool> isWeChatInstalled() {
    return fluwx.isWeChatInstalled;
  }

  ///分享至微信会话
  static void shareToSession({
    String mUrl,
    String mTitle,
    String mDes,
    String thumbnail,
  }) {
    String url = mUrl ?? "http://index.tianjiemedia.com/";
    String title = mTitle ?? "Boss说-追踪老板的言论";
    String des = mDes ?? "深度学习大佬的言论文章，找寻你的成功暗门";
    fluwx.WeChatShareWebPageModel model = fluwx.WeChatShareWebPageModel(
      url,
      title: title,
      description: des,
      scene: fluwx.WeChatScene.SESSION,
      thumbnail: thumbnail.isNullOrEmpty()
          ? fluwx.WeChatImage.asset(R.assetsImgAboutUsLogo)
          : fluwx.WeChatImage.network(thumbnail),
    );
    fluwx.shareToWeChat(model);
  }

  ///分享至微信朋友圈
  static void shareToTimeline(
      {String mUrl, String mTitle, String mDes, String thumbnail}) {
    String url = mUrl ?? "http://index.tianjiemedia.com/";
    String title = mTitle ?? "Boss说-追踪老板的言论";
    String des = mDes ?? "深度学习大佬的言论文章，找寻你的成功暗门";
    fluwx.WeChatShareWebPageModel model = fluwx.WeChatShareWebPageModel(
      url,
      title: title,
      description: des,
      scene: fluwx.WeChatScene.TIMELINE,
      thumbnail: thumbnail.isNullOrEmpty()
          ? fluwx.WeChatImage.asset(R.assetsImgAboutUsLogo)
          : fluwx.WeChatImage.network(thumbnail),
    );
    fluwx.shareToWeChat(model);
  }

  ///分享复制链接
  static void shareCopyLink({String mUrl}) {
    String url = mUrl ?? "http://index.tianjiemedia.com/";

    Clipboard.setData(ClipboardData(text: url))
        .then((value) => BaseTool.toast(msg: "复制成功"));
  }

  ///分享生成的图片至微信会话
  static void shareImgToSession(GlobalKey key) {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    double px = window.devicePixelRatio;
    boundary.toImage(pixelRatio: px).then((image) {
      image.toByteData(format: ImageByteFormat.png).then((byteData) {
        var picBytes = byteData.buffer.asUint8List();
        fluwx.WeChatImage image =
            fluwx.WeChatImage.binary(picBytes.buffer.asUint8List());
        fluwx.WeChatShareImageModel model = fluwx.WeChatShareImageModel(
          image,
          scene: fluwx.WeChatScene.SESSION,
        );
        fluwx.shareToWeChat(model);
      });
    });
  }

  ///分享生成的图片至朋友圈
  static void shareImgToTimeline(GlobalKey key) {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    double px = window.devicePixelRatio;
    boundary.toImage(pixelRatio: px).then((image) {
      image.toByteData(format: ImageByteFormat.png).then((byteData) {
        var picBytes = byteData.buffer.asUint8List();
        fluwx.WeChatImage image =
            fluwx.WeChatImage.binary(picBytes.buffer.asUint8List());
        fluwx.WeChatShareImageModel model = fluwx.WeChatShareImageModel(
          image,
          scene: fluwx.WeChatScene.TIMELINE,
        );
        fluwx.shareToWeChat(model);
      });
    });
  }

  ///屏幕截屏并保存至相册 ios
  static void saveCutImage(GlobalKey key) {
    Permission.storage.status.then((status) {
      if (status.isGranted) {
        RenderRepaintBoundary boundary = key.currentContext.findRenderObject();

        double px = window.devicePixelRatio;

        boundary.toImage(pixelRatio: px).then((image) {
          image.toByteData(format: ImageByteFormat.png).then((byteData) {
            var picBytes = byteData.buffer.asUint8List();

            ImageGallerySaver.saveImage(picBytes.buffer.asUint8List(),
                    quality: 80, name: "dailyTalk")
                .then((result) {
              BaseTool.toast(msg: "图片已保存至相册");
            }, onError: (e,_) {
              print(e.toString());
            });
          });
        });
      }
    });
  }

  ///复制
  static void copyText(String text, {String infix = ""}) {
    String toast = infix.isNullOrEmpty() ? "已复制：$text" : "已复制：$infix：$text";
    Clipboard.setData(ClipboardData(text: text))
        .then((value) => BaseTool.toast(msg: toast));
  }

  ///是否展示小红点
  static bool showRedDots(String id, int currentTime) {
    int lastTime = DataConfig.getIns().getBossTime(id);
    return currentTime >= lastTime;
  }

  ///是否为同一天
  static bool isSameDay(int lastTime) {
    DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastTime);
    DateTime nowDate = DateTime.now();

    return lastDate.year == nowDate.year &&
        lastDate.month == nowDate.month &&
        lastDate.day == nowDate.day;
  }

  ///是否为三天前
  static bool inThreeDays(int time) {
    int three =
        DateTime.now().millisecondsSinceEpoch - (3 * 24 * 60 * 60 * 1000);
    return time >= three;
  }

  static void doAddRead() {
    UserEntity user = Global.user.user.value;

    // int lastTime = UserConfig.getIns().lastReadTime;
    // int nowTime = DateTime.now().millisecondsSinceEpoch;
    // UserConfig.getIns().setLastReadTime = nowTime;
    //
    // if (!isSameDay(lastTime)) {
    //   user.readNum = 0;
    // }

    user.readNum++;
    Global.user.setUser(user);
  }
}
