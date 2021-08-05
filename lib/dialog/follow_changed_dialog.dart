import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showFollowChangedDialog(BuildContext context, bool doFollow) {
  String title = doFollow ? "追踪成功" : "取消成功";
  String content = doFollow ? "后续可在老板-我的追踪里查看" : "已成功取消追踪，将不会实时推送";

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
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
                  R.assetsImgRightGreen,
                  width: 64,
                  height: 64,
                ).marginOn(top: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: BaseColor.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                ).marginOn(top: 8),
                Text(
                  content,
                  style: TextStyle(
                    color: BaseColor.textDarkLight,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                ).marginOn(top: 9, bottom: 20),
              ],
            ),
          ),
        ),
      );
    },
  );
}
