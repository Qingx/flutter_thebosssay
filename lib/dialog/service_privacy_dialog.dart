import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/pages/web_service_privacy_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:get/get.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showServicePrivacyDialog(BuildContext context,
    {Function onDismiss, Function onConfirm}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.72,
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "服务协议",
                  style: TextStyle(
                    color: BaseColor.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      text:
                          """请你务必认真阅读、充分理解"服务条款"和"隐私政策"各条款，包括但不限于，为了向你提供数据、分享等服务所要获取的权限信息。你可以阅读""",
                      style: TextStyle(color: BaseColor.textDark, fontSize: 14),
                      children: [
                        TextSpan(
                            text: "《服务条款》",
                            style: TextStyle(
                                color: BaseColor.accent, fontSize: 14),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => WebServicePrivacyPage(),
                                    arguments: "0");
                              }),
                        TextSpan(
                          text: "和",
                          style: TextStyle(
                              color: BaseColor.textDark, fontSize: 14),
                        ),
                        TextSpan(
                            text: "《隐私政策》",
                            style: TextStyle(
                                color: BaseColor.accent, fontSize: 14),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => WebServicePrivacyPage(),
                                    arguments: "1");
                              }),
                        TextSpan(
                          text: """了解详细信息。如您同意，请点击"同意"开始接受我们的服务。""",
                          style: TextStyle(
                              color: BaseColor.textDark, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: BaseColor.line,
                  margin: EdgeInsets.only(top: 8),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          "暂不使用",
                          style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: false,
                        ),
                      ).onClick(onDismiss),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: BaseColor.line,
                    ),
                    Expanded(
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          "同意",
                          style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: false,
                        ),
                      ).onClick(onConfirm),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
