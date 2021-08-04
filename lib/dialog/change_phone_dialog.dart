import 'package:flutter/material.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

Future<dynamic> showPhoneName(BuildContext context,
    {Function onDismiss, Function(String) onConfirm}) {
  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = FocusNode();
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
            padding: EdgeInsets.only(left: 24, right: 24, top: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "验证当前手机号",
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
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13, color: BaseColor.textDark),
                  decoration: InputDecoration(
                    hintText: "输入当前登录的手机号",
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
                        margin: EdgeInsets.only(left: 16, top: 24),
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
                        focusNode?.unfocus();
                        onConfirm(editingController.text);
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
