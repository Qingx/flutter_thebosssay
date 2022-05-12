import 'dart:io';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/pages/login_phone_wechat.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jverify/jverify.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class JpushApi {
  final String appKey = "f98cfa8459c6510944ebbefd";
  final String appChannel = "developer-default";

  JPush jPush; //极光推送
  Jverify jverify; //极光认证-一键登录

  JpushApi._() {
    jPush = JPush();
    jverify = Jverify();
  }

  static JpushApi _mIns;

  factory JpushApi.ins() => _mIns ??= JpushApi._();

  ///-------极光推送-------
  ///注册极光推送
  void registerJpush() {
    jPush.setup(
      appKey: appKey,
      channel: appChannel,
      production: false,
      debug: false,
    );
  }

  ///添加别名
  void addAlias(String alias, {int count = 6}) {
    if (count <= 0) {
      return;
    }
    jPush.setAlias(alias).then((value) {
      print("JpushAddAlias=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        addAlias(alias, count: count - 1);
      });
    });
  }

  ///添加tags
  void addTags(List<String> tags, {int count = 6}) {
    if (count <= 0) {
      return;
    }

    // var testTags = ["0123456789"];

    jPush.addTags(tags).then((value) {
      print("JpushAddTags=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        addTags(tags, count: count - 1);
      });
    });
  }

  ///删除tags
  void deleteTags(List<String> tags, {int count = 6}) {
    if (count <= 0) {
      return;
    }

    jPush.deleteTags(tags).then((value) {
      print("JpushDeleteTags=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        deleteTags(tags, count: count - 1);
      });
    });
  }

  ///清空所有tags
  void clearTags({int count = 6}) {
    if (count <= 0) {
      return;
    }

    jPush.cleanTags().then((value) {
      print("JpushCleanTags=>$value");
    }, onError: (e, s) {
      print(e);
      Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
        clearTags(count: count - 1);
      });
    });
  }

  ///获取所有tags
  void getAllTags() {
    jPush.getAllTags().then((value) {
      print("JpushGetAllTags=>$value");
    }, onError: (e, s) {
      print(e);
    });
  }

  ///-------极光认证-------
  ///注册极光认证
  void registerJverify() {
    jverify.setup(appKey: appKey, channel: appChannel);
  }

  ///极光认证注册回调
  void registerJverifyCallback() {
    jverify.isInitSuccess().then((value) {
      print('registerJverify:$value');
      bool result = value["result"];
      if (!result) {
        registerJverify();
      }
    });
  }

  ///极光认证预取号
  void doPreLogin({int count = 6}) {
    if (count <= 0) {
      return;
    }

    JpushApi.ins().jverify.preLogin().then((value) {
      print('jverifyPreLogin:$value');

      var code = value["code"];
      if (code != 7000) {
        print('jverifyPreLogin:预取号成功');
        Observable.timer(0, Duration(milliseconds: 500)).listen((event) {
          doPreLogin(count: count - 1);
        });
      } else {
        print('jverifyPreLogin:预取号成功');
      }
    });
  }

  ///自定义控件的点击事件
  void addClickWidgetCallback() {
    jverify.addClikWidgetEventListener("other", (s) {
      print("jverifyClick:$s");
      Get.to(() => LoginPhoneWechatPage());
      jverify.dismissLoginAuthView();
    });
  }

  ///授权页面点击事件监听
  void addAuthClickCallback() {
    jverify.addAuthPageEventListener((event) {
      print('registerJverifyAuthPage:${event.toMap()}');
      if (event.toMap()["code"].toString() == "8") {
        BaseTool.toast(msg: "尝试一键登录中...");
      }
    });
  }

  ///自定义授权页
  JVUIConfig createUIConfig(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    JVUIConfig uiConfig = JVUIConfig();

    uiConfig.navTransparent = true;
    uiConfig.navReturnImgPath = "BackBlack"; //图片必须存在

    uiConfig.logoHidden = true;

    uiConfig.numberFieldWidth = 200;
    uiConfig.numberFieldHeight = 40;

    uiConfig.numberVerticalLayoutItem = JVIOSLayoutItem.ItemLogo;
    uiConfig.numberColor = Colors.black.value;
    uiConfig.numFieldOffsetY = 304;
    uiConfig.numberSize = 20;

    uiConfig.sloganOffsetY = 20;
    uiConfig.sloganVerticalLayoutItem = JVIOSLayoutItem.ItemNumber;
    uiConfig.sloganTextColor = Colors.black.value;
    uiConfig.sloganTextSize = 15;

    uiConfig.logBtnWidth = screenWidth.toInt() - 56;
    uiConfig.logBtnHeight = 50;
    uiConfig.logBtnOffsetY = 32;
    uiConfig.logBtnVerticalLayoutItem = JVIOSLayoutItem.ItemSlogan;
    uiConfig.logBtnText = "一键登录";
    uiConfig.logBtnTextColor = Colors.white.value;
    uiConfig.logBtnTextSize = 16;
    uiConfig.loginBtnNormalImage = "LoginBlue"; //图片必须存在
    uiConfig.loginBtnPressedImage = "LoginBlue"; //图片必须存在
    uiConfig.loginBtnUnableImage = "LoginBlue"; //图片必须存在

    uiConfig.privacyState = true; //设置默认勾选
    uiConfig.privacyCheckboxSize = 20;
    uiConfig.checkedImgPath = "CheckSelect"; //图片必须存在
    uiConfig.uncheckedImgPath = "CheckNormal"; //图片必须存在
    uiConfig.privacyCheckboxInCenter = true;

    uiConfig.privacyOffsetY = 80; // 距离底部距离
    uiConfig.privacyVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
    uiConfig.clauseName = "服务条款";
    uiConfig.clauseUrl = "http://file.tianjiemedia.com/serviceProtocol.html";
    uiConfig.clauseBaseColor = BaseColor.textGray.value;
    uiConfig.clauseNameTwo = "隐私政策";
    uiConfig.clauseUrlTwo = "http://file.tianjiemedia.com/privacyService.html";
    uiConfig.clauseColor = BaseColor.accent.value;
    uiConfig.privacyText = ["我已阅读并同意", "和", "、"];
    uiConfig.privacyTextSize = 13;

    uiConfig.privacyNavColor = Colors.white.value;
    uiConfig.privacyStatusBarStyle = JVIOSBarStyle.StatusBarStyleLightContent;
    uiConfig.privacyNavTitleTextColor = BaseColor.textDark.value;
    uiConfig.privacyNavTitleTextSize = 16;
    uiConfig.privacyNavTitleTitle1 = "服务条款";
    uiConfig.privacyNavTitleTitle2 = "隐私政策";
    uiConfig.privacyNavReturnBtnImage = "BackBlack"; //图片必须存在;
    uiConfig.needStartAnim = true;
    uiConfig.needCloseAnim = true;

    return uiConfig;
  }

  ///授权页 自定义控件
  JVCustomWidget getTitle() {
    JVCustomWidget widget =
        JVCustomWidget("title", JVCustomWidgetType.textView);
    widget.title = "欢迎来到Boss说";
    widget.textAlignment = JVTextAlignmentType.left;
    widget.titleFont = 28.0;
    widget.left = 28;
    widget.top = 120;
    widget.width = 216;
    widget.height = 40;
    return widget;
  }

  ///授权页 自定义控件
  JVCustomWidget getNotice() {
    JVCustomWidget widget =
        JVCustomWidget("notice", JVCustomWidgetType.textView);
    widget.title = "首次登录将自动注册";
    widget.titleColor = BaseColor.textGray.value;
    widget.titleFont = 14.0;
    widget.left = 28;
    widget.top = 160;
    widget.width = 140;
    widget.height = 40;
    return widget;
  }

  ///授权页 自定义控件 其他登录方式
  JVCustomWidget getOther(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    JVCustomWidget widget =
        JVCustomWidget("other", JVCustomWidgetType.textView);
    widget.title = "其他方式登录";
    widget.titleFont = 14.0;
    widget.left = (screenWidth ~/ 2) - 48;
    widget.top = 472;
    widget.width = 96;
    widget.height = 40;
    widget.titleColor = BaseColor.textGray.value;
    widget.isClickEnable = true;
    widget.textAlignment = JVTextAlignmentType.center;
    return widget;
  }

  ///一键登录
  void doLogin(BuildContext context) {
    jverify.checkVerifyEnable().then((value) {
      print('jverifyCheckVerify:$value');
      bool result = value["result"];

      if (result) {
        jverify.setCustomAuthorizationView(
          false,
          createUIConfig(context),
          widgets: [
            getTitle(),
            getNotice(),
            getOther(context),
          ],
        );

        addClickWidgetCallback();

        jverify.loginAuth(false).then((value) {
          print('jverifyLogin:$value}');

          var code = value["code"].toString();
          if (code == "6000") {
            UserApi.ins()
                .obtainJverifyLogin(value["message"].toString())
                .flatMap((event) {
                  UserConfig.getIns().token = event.token;
                  Global.user.setUser(event.userInfo);

                  TalkingApi.ins().obtainLogin(event.userInfo.id);

                  JpushApi.ins().addAlias(event.userInfo.id);

                  if (!event.userInfo.tags.isNullOrEmpty()) {
                    JpushApi.ins().addTags(event.userInfo.tags);
                  }

                  CacheProvider.getIns().clearBoss();
                  CacheProvider.getIns().clearArticle();

                  return AppApi.ins().obtainGetAllFollowBoss("-1");
                })
                .onErrorReturn([])
                .flatMap((value) {
                  CacheProvider.getIns().insertBossList(value);

                  return AppApi.ins()
                      .obtainGetTackArticleList(PageParam(), "-1");
                })
                .onErrorReturn(BaseEmpty.emptyArticle)
                .timeout(Duration(seconds: 8))
                .listen((event) {
                  CacheProvider.getIns().insertArticle(event);
                  DataConfig.getIns().fromSplash = true;

                  jverify.dismissLoginAuthView();
                  Get.offAll(() => HomePage());
                }, onError: (res) {
                  BaseTool.toast(msg: "一键登录失败");
                });
          } else if (code == "6002") {
            print('jverifyLogin:取消一键登录');
          } else {
            Get.to(() => LoginPhoneWechatPage());
          }
        });
      } else {
        Get.to(() => LoginPhoneWechatPage());
      }
    });
  }
}
