import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/change_name_dialog.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:get/get.dart';

class ChangeInfoPage extends StatelessWidget {
  ChangeInfoPage({Key key}) : super(key: key);

  List<String> names = ["账号昵称", "账号ID", "登录手机号"];

  void tryLogout() {
    DataConfig.getIns().setTempId = BaseTool.createTempId();
    UserConfig.getIns().clear();
    Global.user.setUser(BaseEmpty.emptyUser);
    Get.offAll(() => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          children: [
            Container(
              color: BaseColor.loadBg,
              child: BaseWidget.statusBar(context, true),
            ),
            Container(
              color: BaseColor.loadBg,
              height: 44,
              padding: EdgeInsets.only(left: 12, right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 28),
                      alignment: Alignment.center,
                      child: Text(
                        "账号修改",
                        style: TextStyle(
                            fontSize: 16,
                            color: BaseColor.textDark,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: listWidget(context),
            ),
            Container(
              height: 48,
              margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
                color: BaseColor.loadBg,
              ),
              child: Text(
                "退出登录",
                style: TextStyle(
                    fontSize: 16,
                    color: BaseColor.textDark,
                    fontWeight: FontWeight.bold),
                softWrap: false,
                maxLines: 1,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ).onClick(tryLogout),
          ],
        ),
      ),
    );
  }

  Widget listWidget(context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return listItemWidget(index, context);
        },
        itemCount: 3,
      ),
    );
  }

  Widget listItemWidget(index, context) {
    return Container(
      height: 57,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  names[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: BaseColor.textDark,
                  ),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 16),
                Expanded(
                  child: Obx(
                    () => Text(
                      index == 0
                          ? Global.user.user.value == BaseEmpty.emptyUser
                              ? "请先登录！"
                              : Global.user.user.value.nickName
                          : index == 1
                              ? Global.user.user.value == BaseEmpty.emptyUser
                                  ? "游客：${DataConfig.getIns().tempId.substring(0, 12)}..."
                                  : Global.user.user.value.id
                              : Global.user.user.value == BaseEmpty.emptyUser
                                  ? "ID：${Global.user.user.value.id}"
                                  : Global.user.user.value.phone
                                      .hidePhoneNumber(),
                      style: TextStyle(fontSize: 14, color: BaseColor.accent),
                      softWrap: false,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).marginOn(right: index == 1 ? 66 : 18),
                  ),
                ),
                index == 1
                    ? SizedBox()
                    : Image.asset(R.assetsImgChangeInfo, width: 16, height: 16)
                        .marginOn(right: 32),
              ],
            ),
          ),
          Container(
            height: 1,
            color: BaseColor.line,
          ),
        ],
      ),
    ).onClick(() {
      onClickItem(index, context);
    });
  }

  void onClickItem(index, context) {
    if (index == 0) {
      showChangeName(context, onDismiss: () {
        Get.back();
      }, onConfirm: (name) {
        tryChangeName(name, context);
      });
    }
  }

  void tryChangeName(name, context) {
    UserEntity entity = Global.user.user.value;

    if (entity.nickName != name) {
      BaseWidget.showLoadingAlert("正在更新...", context);
      UserApi.ins().obtainUpdateUser(nickName: name).listen((event) {
        entity.nickName = name;
        Global.user.setUser(entity);
        Get.back();
        Get.back();
        BaseTool.toast(msg: "更新成功");
      });
    } else {
      Get.back();
      BaseTool.toast(msg: "昵称重复，修改失败");
    }
  }
}
