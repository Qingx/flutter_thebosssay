import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/pages/guide_page.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class TestSplashPage extends StatefulWidget {
  const TestSplashPage({Key key}) : super(key: key);

  @override
  _TestSplashPageState createState() => _TestSplashPageState();
}

class _TestSplashPageState extends State<TestSplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(),
    );
  }

  @override
  void initState() {
    super.initState();

    String mJson = '''
        [{"name": "John Smith","email": "john@example.com"},
        {"name": "John Smith","email": "john@example.com"},
        {"name": "John Smith","email": "john@example.com"}]
        ''';

    print('aaaa==>$mJson');

    List<dynamic> map = json.decode(mJson);

    map.forEach((element) {
      Map<String, dynamic> value = element;
      if (value["name"] == "John Smith") {
        value["name"] = "ddddddddddd";
      }
      print('cccc==>${value}');
    });
  }
}
