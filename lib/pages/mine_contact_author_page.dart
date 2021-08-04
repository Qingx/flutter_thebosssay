import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';

class ContactAuthorPage extends StatelessWidget {
  ContactAuthorPage({Key key}) : super(key: key);

  List<String> images = [
    R.assetsImgContact1,
    R.assetsImgContact2,
    R.assetsImgContact3,
    R.assetsImgContact4
  ];

  List<String> names = ["某篇文章冒犯了您的权益或涉及侵权", "期望新增更多的BOSS", "给APP提建议", "更多合作"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          children: [
            topWidget(context),
            Expanded(
              child: listWidget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget topWidget(context) {
    return Container(
      height: 176 + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        color: BaseColor.accent,
      ),
      child: Column(
        children: [
          BaseWidget.statusBar(context, true),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 12),
            height: 44,
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ).onClick(() {
              Get.back();
            }),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "如遇以下问题，请邮箱联系我们",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  height: 96,
                  padding: EdgeInsets.only(left: 16, right: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "联系邮箱:",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                              ),
                              softWrap: false,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "cd1369@1369net.com",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              softWrap: false,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(top: 8),
                          ],
                        ),
                      ),
                      Image.asset(
                        R.assetsImgLogo,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget listWidget(context) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeTop: true,
      child: GridView.builder(
        padding: EdgeInsets.only(top: 32, left: 16, right: 16),
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return itemWidget(index, context);
        },
        itemCount: 4,
      ),
    );
  }

  Widget itemWidget(index, context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Image.asset(
            images[index],
            width: (MediaQuery.of(context).size.width - 48) / 2 - 32,
            height: 78,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                names[index],
                style: TextStyle(
                    fontSize: 13,
                    color: BaseColor.textDark,
                    fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
