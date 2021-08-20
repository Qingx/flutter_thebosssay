import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/hint_controller.dart';
import 'package:flutter_boss_says/config/page_param.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/db/article_db_provider.dart';
import 'package:flutter_boss_says/data/db/boss_db_provider.dart';
import 'package:flutter_boss_says/data/db/label_db_provider.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/service_privacy_dialog.dart';
import 'package:flutter_boss_says/pages/start_guide_page.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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

    BossApi.ins().obtainBossLabels().onErrorReturn([]).flatMap((value) {
      value = [BaseEmpty.emptyLabel, ...value];

      return LabelDbProvider.ins().insertList(value);
    }).onErrorReturn([]).flatMap((value) {
      return BossApi.ins().obtainGuideBoss();
    }).listen(
      (event) {
        Get.offAll(() => StartGuidePage(), arguments: event);
      },
      onError: (res) {
        Get.offAll(() => HomePage());
      },
      onDone: () {
        DataConfig.getIns().firstUseApp = false;
      },
    );
  }

  void doSecondUse() {
    BossApi.ins().obtainBossLabels().onErrorReturn([]).flatMap((value) {
      value = [BaseEmpty.emptyLabel, ...value];

      return LabelDbProvider.ins().insertList(value);
    }).onErrorReturn([]).flatMap((value) {
      return BossApi.ins().obtainFollowBossList("-1", false);
    }).onErrorReturn([]).flatMap((value) {
      return BossDbProvider.ins().insertList(value);
    }).onErrorReturn([]).flatMap((value) {
      return BossApi.ins().obtainTackArticle(PageParam(), "-1");
    }).flatMap((value) {
      return ArticleDbProvider.ins().insertList(value.records);
    }).onErrorReturn([]).listen(
      (event) {
        Get.offAll(() => HomePage());
      },
      onError: (res) {
        print("ArticleDbError=>$res");
        Get.offAll(() => HomePage());
      },
      onDone: () {
        Global.user.setUser(UserConfig.getIns().user);
      },
    );
  }

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
}
