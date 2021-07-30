import 'package:flutter/material.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showNewFolderDialog(BuildContext context,
    {Function onDismiss, Function(String) onConfirm}) {
  TextEditingController editingController = TextEditingController();
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Container(
            width: 264,
            height: 192,
            padding: EdgeInsets.only(left: 24, right: 24, top: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "新建收藏夹",
                  style: TextStyle(
                    fontSize: 16,
                    color: BaseColor.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: false,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: editingController,
                  cursorColor: BaseColor.accent,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  autofocus: false,
                  style: TextStyle(fontSize: 13, color: BaseColor.textDark),
                  decoration: InputDecoration(
                    hintText: "输入文件夹名称",
                    hintStyle:
                        TextStyle(fontSize: 13, color: BaseColor.textGray),
                    fillColor: BaseColor.loadBg,
                    filled: true,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: onConfirm,
                ).marginOn(top: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: BaseColor.loadBg,
                        ),
                        child: Text(
                          "取消",
                          style: TextStyle(
                            fontSize: 14,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: false,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).onClick(onDismiss),
                    ),
                    Expanded(
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 16, top: 28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: BaseColor.accent,
                        ),
                        child: Text(
                          "确认",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: false,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).onClick(() {
                        if (!editingController.text.isNullOrEmpty()) {
                          onConfirm(editingController.text);
                        }
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
