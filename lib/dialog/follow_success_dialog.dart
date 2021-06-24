import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showFollowSuccessDialog(
    BuildContext context, {Function onDismiss, Function onConfirm}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  R.assetsImgBossSuccess,
                  width: 135,
                  height: 108,
                ).marginOn(top: 16),
                Text(
                  "追踪成功",
                  style: TextStyle(color: BaseColor.textDark, fontSize: 16),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 16),
                Text(
                  "需要实时推送该老板的言论吗？",
                  style: TextStyle(color: BaseColor.textGray, fontSize: 14),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 8),
                Container(
                  height: 32,
                  margin: EdgeInsets.only(top: 16,bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 32,
                        padding: EdgeInsets.only(left: 12,right: 12),
                        alignment: Alignment.center,
                        child: Text(
                          "暂不开启",
                          style: TextStyle(
                              fontSize: 16, color: BaseColor.textGray),
                          softWrap: false,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).onClick(onDismiss),
                      Container(
                        height: 32,
                        padding: EdgeInsets.only(left: 12,right: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: BaseColor.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "开启推送",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          softWrap: false,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).onClick(onConfirm),
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