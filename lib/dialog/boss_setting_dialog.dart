import 'package:flutter/material.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showBossSettingDialog(BuildContext context,
    {Function onDismiss, Function onConfirm}) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 24),
                  alignment: Alignment.center,
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1a2343C2),
                  ),
                  child: Image.asset(R.assetsImgBossSetting,
                      height: 64, width: 64, fit: BoxFit.cover),
                ),
                Text(
                  "是否需要对他开启单独推送？",
                  style: TextStyle(fontSize: 16, color: BaseColor.textDark),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 20),
                Container(
                  height: 1,
                  color: BaseColor.line,
                  margin: EdgeInsets.only(top: 24),
                ),
                Container(
                  height: 56,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          child: Text(
                            "取消",
                            style: TextStyle(fontSize: 16, color: Colors.red),
                            softWrap: false,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ).onClick(onDismiss),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: BaseColor.line,
                      ),
                      Expanded(
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          child: Text(
                            "开启推送",
                            style: TextStyle(
                                fontSize: 16, color: BaseColor.accent),
                            softWrap: false,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ).onClick(onConfirm),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
