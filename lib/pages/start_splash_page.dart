import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/service_privacy_dialog.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/pages/start_guide_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class StartSplashPage extends StatefulWidget {
  const StartSplashPage({Key key}) : super(key: key);

  @override
  _StartSplashPageState createState() => _StartSplashPageState();
}

class _StartSplashPageState extends State<StartSplashPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    DataConfig.getIns().doAfterCreated((sp) {
      UserConfig.getIns().doAfterCreated((sp) {
        Global.user = Get.find<UserController>(tag: "user");
        Global.hint = Get.find<HintController>(tag: "hint");
        Global.user.setUser(UserConfig.getIns().user);

        if (DataConfig.getIns().firstUserApp) {
          doFirstUse();
        } else {
          doSecondUse();
        }
      });
    });
  }

  void doFirstUse() {
    UserApi.ins().obtainCheckServer().listen((event) {}, onDone: () {
      showServicePrivacyDialog(
        context,
        onDismiss: () {
          exit(0);
        },
        onConfirm: doAgreeService,
      );
    });
  }

  void doAgreeService() {
    BaseWidget.showLoadingAlert("努力加载Boss...", context);
    AppApi.ins().obtainGetLabelList().onErrorReturn([]).flatMap((value) {
      CacheProvider.getIns().insertLabelList(value);

      return AppApi.ins().obtainGetGuideBossList();
    }).listen((event) {
      Get.offAll(() => StartGuidePage(), arguments: event);
    }, onError: (res) {
      Get.offAll(() => HomePage(), transition: Transition.fadeIn);
    }, onDone: () {
      DataConfig.getIns().firstUseApp = false;
    });
  }

  void doSecondUse() {
    CacheProvider.getIns().clearAll();

    AppApi.ins()
        .obtainGetLabelList()
        .onErrorReturn([])
        .flatMap((value) {
          CacheProvider.getIns().insertLabelList(value);

          return AppApi.ins().obtainGetAllFollowBoss("-1");
        })
        .onErrorReturn([])
        .flatMap((value) {
          CacheProvider.getIns().insertBossList(value);

          return AppApi.ins().obtainGetTackArticleList(PageParam(), "-1");
        })
        .onErrorReturn(BaseEmpty.emptyArticle)
        .flatMap((value) {
          CacheProvider.getIns().insertArticle(value);

          return UserApi.ins().obtainRefresh();
        })
        .timeout(Duration(seconds: 8))
        .listen((event) {
          UserConfig.getIns().token = event.token;
          Global.user.setUser(event.userInfo);

          if (!event.userInfo.tags.isNullOrEmpty()) {
            JpushApi.ins().addTags(event.userInfo.tags);
          }

          Get.offAll(() => HomePage(), transition: Transition.fadeIn);
        }, onError: (res) {
          print(res);
          Get.offAll(() => HomePage(), transition: Transition.fadeIn);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              width: 24,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.2,
              ),
              child: Image.asset(
                R.assetsImgSplashImage1,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 48,
              margin: EdgeInsets.only(top: 32),
              child: Image.asset(
                R.assetsImgSplashImage2,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(child: SizedBox()),
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(bottom: 12),
              child: Image.asset(
                R.assetsImgSplashImage3,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 32),
              child: Text(
                "BOSS说-追踪大佬的言论",
                style: TextStyle(
                  color: BaseColor.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
