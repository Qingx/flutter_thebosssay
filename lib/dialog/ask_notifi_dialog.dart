import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showAskNotifiDialog(BuildContext context,
    {Function onDismiss, Function onConfirm}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context){
        return Center(
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: Container(
              width: 260,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    R.assetsImgNotification,
                    width: 64,
                    height: 64,
                  ).marginOn(top: 32),
                  Text(
                    "已关闭boss说的通知权限\n请先到手机设置中开启",
                    style: TextStyle(color: BaseColor.textGray, fontSize: 14),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(top: 24, left: 16, right: 16),
                  Container(
                    height: 36,
                    margin:
                    EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: BaseColor.loadBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "稍后再说",
                                style: TextStyle(
                                    fontSize: 14, color: BaseColor.textDark),
                                softWrap: false,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ).onClick(onDismiss)),
                        Expanded(
                          child: Container(
                            height: 36,
                            margin: EdgeInsets.only(left: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: BaseColor.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "立即前往",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                              softWrap: false,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ).onClick(onConfirm),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
  );
}
