import 'package:flutter/services.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:uuid/uuid.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class BaseTool {
  static bool eq(double num1, double num2) {
    return (num1 - num2).abs() <= 0.000005;
  }

  static void toast({String msg}) {
    Fluttertoast.showToast(msg: msg);
  }

  static final _uuid = Uuid();

  static String createTempId() {
    String uuid = _uuid.v4().replaceAll(RegExp(r'-'), "");
    return "temp$uuid";
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
      return "时间戳异常";
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
      return "时间戳异常";
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
}
