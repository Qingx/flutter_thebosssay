import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/pages/guide_page.dart';
import 'package:flutter_boss_says/pages/splash_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_sp.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    BaseSP.init();

    DataConfig.getIns().doAfterCreated((sp) {
      UserConfig.getIns().doAfterCreated((sp) {
        Get.lazyPut(() => Global.user, tag: "user");

        bool isFirstUseApp = DataConfig.getIns().firstUserApp == "empty";

        if (DataConfig.getIns().tempId == "empty") {
          DataConfig.getIns().setTempId = BaseTool.createTempId();
        }

        if (isFirstUseApp) {
          Get.off(() => GuidePage());
        } else {
          Get.off(() => SplashPage());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(backgroundColor: Colors.white),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          alignment: Alignment.topRight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(R.assetsImgSplash),
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
