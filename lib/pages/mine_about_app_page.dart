import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/pages/web_service_privacy_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class MineAboutAppPage extends StatefulWidget {
  const MineAboutAppPage({Key key}) : super(key: key);

  @override
  _MineAboutAppPageState createState() => _MineAboutAppPageState();
}

class _MineAboutAppPageState extends State<MineAboutAppPage> {
  TapGestureRecognizer serviceTap;
  TapGestureRecognizer privacyTap;

  @override
  void dispose() {
    super.dispose();

    serviceTap?.dispose();
    privacyTap?.dispose();
  }

  @override
  void initState() {
    super.initState();

    serviceTap = TapGestureRecognizer();
    privacyTap = TapGestureRecognizer();
  }

  void showService() {
    Get.to(() => WebServicePrivacyPage(), arguments: "0");
  }

  void showPrivacy() {
    Get.to(() => WebServicePrivacyPage(), arguments: "1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage(R.assetsImgAboutUsBg),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(0),
                  ),
                ),
              ),
            ),
            bodyWidget().positionOn(top: 0, left: 0, right: 0),
            copyrightWidget().positionOn(left: 0, right: 0, bottom: 48)
          ],
        ),
      ),
    );
  }

  Widget bodyWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: BaseWidget.statusBar(context, true),
          ),
          Container(
            height: 44,
            padding: EdgeInsets.only(left: 12, right: 16),
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.arrow_back,
              color: BaseColor.textDark,
              size: 28,
            ).onClick(() {
              Get.back();
            }),
          ),
          Image.asset(
            R.assetsImgAboutUsLogo,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ).marginOn(left: 56, top: 16),
          Container(
            width: 96,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 56, top: 4),
            child: Text(
              "BOSS说",
              style: TextStyle(
                fontSize: 24,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          Text(
            "当前版本：${Global.versionName}${Global.build}",
            style: TextStyle(fontSize: 12, color: BaseColor.textDark),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.start,
          ).marginOn(left: 56),
          Text(
            """Boss说是一款深度追踪知名老板文章和言论的资讯分享类APP，将大家熟知的企业家、投资人、媒体人、创业者等等商业优秀人物归纳分类，生成boss主页。同时将boss的新闻资讯、生平经历，思考感悟等相关文章精编汇总，成为以boss自身为出发点的专题合集，为从商的用户提供有价值的参考学习资料。
Boss说APP期待和同志者一起追踪有深度的大佬，欣赏不一样的思想和境界，找寻他们成功的法则。""",
            style: TextStyle(
              fontSize: 15,
              color: BaseColor.textGray,
            ),
            textAlign: TextAlign.justify,
            softWrap: true,
          ).marginOn(left: 52, right: 52, top: 56),
        ],
      ),
    );
  }

  Widget copyrightWidget() {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "©2021成都一三六九网络科技有限公司\n",
          style: TextStyle(color: BaseColor.textGray, fontSize: 12),
          children: [
            TextSpan(
                text: " 服务条款 ",
                style: TextStyle(color: BaseColor.accent, fontSize: 12),
                recognizer: serviceTap..onTap = showService),
            TextSpan(
              text: "|",
              style: TextStyle(color: BaseColor.textGray, fontSize: 12),
            ),
            TextSpan(
                text: " 隐私政策 ",
                style: TextStyle(color: BaseColor.accent, fontSize: 12),
                recognizer: privacyTap..onTap = showPrivacy),
          ],
        ),
      ),
    );
  }
}
