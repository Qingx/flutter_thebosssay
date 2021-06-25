import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showFollowCancelDialog(BuildContext context,
    {Function onDismiss}) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Container(
            width: 264,
            height: 264,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 108,
                  width: 64,
                  margin: EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  child: Image.asset(
                    R.assetsImgRightGreen,
                    width: 72,
                    height: 72,
                  ),
                ),
                Text(
                  "取消成功",
                  style: TextStyle(
                      color: BaseColor.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "已成功取消追踪，将不会实时推送",
                  style: TextStyle(color: BaseColor.textGray, fontSize: 14),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 8),
                Container(
                  height: 36,
                  margin:
                      EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 24),
                  padding: EdgeInsets.only(left: 12, right: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BaseColor.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "好的",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ).onClick(onDismiss),
              ],
            ),
          ),
        ),
      );
    },
  );
}
