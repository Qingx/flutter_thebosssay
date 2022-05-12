import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showAskPushDialog(BuildContext context,
    {Function onDismiss, Function onConfirm, bool isBatch = false}) {
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
                  R.assetsImgBossSuccess,
                  width: 135,
                  height: 108,
                ).marginOn(top: 16),
                Text(
                  "追踪成功",
                  style: TextStyle(
                    color: BaseColor.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 8),
                Text(
                  isBatch ? "需要实时推送老板的言论吗？" : "需要实时推送该老板的言论吗？",
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
                          "暂不开启",
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
                            "开启推送",
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
