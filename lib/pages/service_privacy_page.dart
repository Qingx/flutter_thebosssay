import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/boss_service_privacy.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class ServicePrivacyPage extends StatefulWidget {
  const ServicePrivacyPage({Key key}) : super(key: key);

  @override
  _ServicePrivacyPageState createState() => _ServicePrivacyPageState();
}

class _ServicePrivacyPageState extends State<ServicePrivacyPage> {
  String code;
  String title;
  String url;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    code = Get.arguments as String;
    title = code == "0" ? "服务条款" : "隐私政策";
    url = code == "0" ? BossServicePrivacy.service : BossServicePrivacy.privacy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              color: Colors.white,
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 28),
                      alignment: Alignment.center,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                removeTop: true,
                removeBottom: true,
                context: context,
                child: ListView(
                  children: [
                    Html(
                      data: url,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
