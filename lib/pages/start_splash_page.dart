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
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

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
        Get.offAll(() => HomePage(), transition: Transition.fadeIn);
      },
      onDone: () {
        DataConfig.getIns().firstUseApp = false;
      },
    );
  }

  void doSecondUse() {
    LabelDbProvider.ins().deleteAll().flatMap((value) {
      return BossApi.ins().obtainBossLabels();
    }).onErrorReturn([]).flatMap((value) {
      value = [BaseEmpty.emptyLabel, ...value];

      return LabelDbProvider.ins().insertList(value);
    }).onErrorReturn([]).flatMap((value) {
      return BossDbProvider.ins().deleteAll();
    }).flatMap((value) {
      return BossApi.ins().obtainFollowBossList("-1", false);
    }).flatMap((value) {
      return BossDbProvider.ins().insertList(value);
    }).onErrorReturn([]).flatMap((value) {
      return ArticleDbProvider.ins().deleteAll();
    }).flatMap((value) {
      return BossApi.ins().obtainTackArticle(PageParam(), "-1");
    }).flatMap((value) {
      DataConfig.getIns().tackTotalNum = value.total;
      DataConfig.getIns().tackHasData = value.hasData;

      return ArticleDbProvider.ins().insertList(value.records);
    }).listen(
      (event) {
        Get.offAll(() => HomePage(), transition: Transition.fadeIn);
      },
      onError: (res) {
        print(res);
        Get.offAll(() => HomePage(), transition: Transition.fadeIn);
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
