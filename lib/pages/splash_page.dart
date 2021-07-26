import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/db/boss_db_provider.dart';
import 'package:flutter_boss_says/dialog/service_privacy_dialog.dart';
import 'package:flutter_boss_says/pages/guide_page.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.topRight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.assetsImgTestSplash),
            alignment: Alignment.center,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //极光申请推送权限
    Global.jPush.applyPushAuthority();

    DataConfig.getIns().doAfterCreated((sp) {
      UserConfig.getIns().doAfterCreated((sp) {
        Global.user = Get.find<UserController>(tag: "user");
        Global.hint = Get.find<HintController>(tag: "hint");

        initData();
      });
    });
  }

  void initData() {
    BossApi.ins().obtainBossLabels().onErrorReturn([]).flatMap((value) {
      value = [BaseEmpty.emptyLabel, ...value];
      DataConfig.getIns().setBossLabels = value;

      return BossApi.ins()
          .obtainAllBoss(DataConfig.getIns().updateTime)
          .onErrorReturn([]);
    }).listen((event) {
      onData(event);
    });
  }

  void onData(List<BossInfoEntity> event) {
    bool firstUseApp = DataConfig.getIns().firstUserApp == "empty";

    if (!event.isNullOrEmpty()) {
      BossDbProvider.getIns().insertListByBean(event);
      DataConfig.getIns().setUpdateTime = DateTime.now().millisecondsSinceEpoch;
    }

    if (firstUseApp && !event.isNullOrEmpty()) {
      jumpPage(true, list: event.where((element) => element.guide).toList());
    } else {
      UserEntity entity = UserConfig.getIns().user;
      Global.user.setUser(entity);

      jumpPage(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void jumpPage(bool firstUse, {List<BossInfoEntity> list}) {
    if (firstUse) {
      showServicePrivacyDialog(context, onDismiss: () {
        exit(0);
      }, onConfirm: () {
        Get.offAll(() => GuidePage(), arguments: list);
      });
    } else {
      Get.offAll(() => HomePage());
    }
  }
}
