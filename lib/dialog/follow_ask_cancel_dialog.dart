import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showFollowAskCancelDialog(BuildContext context,
    {Function onDismiss, Function onConfirm}) {
  return showDialog(
    barrierDismissible: true,
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
                  R.assetsImgBossFail,
                  width: 135,
                  height: 108,
                ).marginOn(top: 16),
                Text(
                  "确定要取消关注吗？",
                  style: TextStyle(color: BaseColor.textDark, fontSize: 16),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 8),
                Text(
                  "取消追踪后将不再关注该boss",
                  style: TextStyle(color: BaseColor.textGray, fontSize: 14),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 8),
                Container(
                  height: 36,
                  margin:
                      EdgeInsets.only(top: 16, bottom: 20, left: 24, right: 24),
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
                          "取消",
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
                            "确定",
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
