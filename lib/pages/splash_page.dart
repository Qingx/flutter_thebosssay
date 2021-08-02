import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/db/boss_db_provider.dart';
import 'package:flutter_boss_says/dialog/service_privacy_dialog.dart';
import 'package:flutter_boss_says/pages/guide_page.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription connectDis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Image.asset(
        R.assetsImgSplash,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    DataConfig.getIns().doAfterCreated((sp) {
      UserConfig.getIns().doAfterCreated((sp) {
        Global.user = Get.find<UserController>(tag: "user");
        Global.hint = Get.find<HintController>(tag: "hint");

        bool firstUseApp = DataConfig.getIns().firstUserApp;

        if (firstUseApp) {
          firstUse();
        } else {
          initData();
        }
      });
    });
  }

  ///第一次使用进入app
  void firstUse() {
    UserApi.ins().obtainCheckServer().listen((event) {}, onDone: () {
      showServicePrivacyDialog(context, onDismiss: () {
        exit(0);
      }, onConfirm: () {
        Connectivity().checkConnectivity().then((result) {
          if (result == ConnectivityResult.none) {
            BaseTool.toast(msg: "网络异常，请开启网络权限");
          }
          initData();
        });
      });
    });
  }

  ///初始化数据
  void initData() {
    BossApi.ins().obtainBossLabels().onErrorReturn([]).flatMap((value) {
      value = [BaseEmpty.emptyLabel, ...value];
      DataConfig.getIns().setBossLabels = value;

      return BossApi.ins()
          .obtainAllBoss(DataConfig.getIns().updateTime)
          .onErrorReturn([]);
    }).listen((event) {
      doOnData(event);
    });
  }

  ///处理数据
  void doOnData(List<BossInfoEntity> event) {
    if (!event.isNullOrEmpty()) {
      DataConfig.getIns().setUpdateTime = DateTime.now().millisecondsSinceEpoch;
      BossDbProvider.getIns().insertListByBean(event);
    }

    if (DataConfig.getIns().firstUserApp && !event.isNullOrEmpty()) {
      DataConfig.getIns().firstUseApp = false;
      var list = event.where((element) => element.guide).toList();

      Get.offAll(() => GuidePage(),
          arguments: list, transition: Transition.fadeIn);
    } else {
      Global.user.setUser(UserConfig.getIns().user);

      Get.offAll(() => HomePage(), transition: Transition.fadeIn);
    }
  }

  @override
  void dispose() {
    super.dispose();

    connectDis?.cancel();
  }
}
