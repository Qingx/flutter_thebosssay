import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/pages/guide_page.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int currentTime = 5;
  StreamSubscription<int> mDispose;

  @override
  Widget build(BuildContext context) {
    double topMargin = MediaQuery.of(context).padding.top;
    double rightMargin = 24;
    Color timeBg = Color(0x4d000000);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        alignment: Alignment.topRight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.assetsImgTestSplash),
            alignment: Alignment.center,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(top: topMargin, right: rightMargin),
          width: 48,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: timeBg,
          ),
          child: Center(
            child: Text(
              "${currentTime}s",
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    DataConfig.getIns().doAfterCreated((sp) {
      UserConfig.getIns().doAfterCreated((sp) {
        Global.user = Get.find<UserController>(tag: "user");

        bool firstUseApp = DataConfig.getIns().firstUserApp == "empty";

        if (firstUseApp) {
          BossApi.ins().obtainGuideBoss().listen((event) {
            countTime(true, list: event.records);
          });
        } else {
          countTime(false);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    mDispose?.cancel();
  }

  ///倒计时
  void countTime(bool firstUse, {List<BossInfoEntity> list}) {
    if (mDispose != null) {
      mDispose.cancel();
    }

    mDispose = Observable.periodic(Duration(seconds: 1), (i) => i)
        .take(6)
        .listen((event) {
      currentTime--;

      if (currentTime < 0) {
        if (firstUse) {
          Get.off(() => GuidePage(), arguments: list);
        } else {
          Get.off(() => HomePage());
        }

        mDispose?.cancel();
      } else {
        setState(() {});
      }
    });
  }
}
