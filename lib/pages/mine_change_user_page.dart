import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/db/article_db_provider.dart';
import 'package:flutter_boss_says/data/db/boss_db_provider.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/ask_bind_dialog.dart';
import 'package:flutter_boss_says/dialog/change_name_dialog.dart';
import 'package:flutter_boss_says/dialog/change_phone_dialog.dart';
import 'package:flutter_boss_says/pages/home_page.dart';
import 'package:flutter_boss_says/pages/user_bind_phone_page.dart';
import 'package:flutter_boss_says/pages/user_change_phone_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:get/get.dart';

class MineChangeUserPage extends StatefulWidget {
  const MineChangeUserPage({Key key}) : super(key: key);

  @override
  _MineChangeUserPageState createState() => _MineChangeUserPageState();
}

class _MineChangeUserPageState extends State<MineChangeUserPage> {
  List<String> names = ["账号昵称", "账号ID", "登录手机号", "登录微信昵称"];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    weChatCallback();
  }

  ///尝试退出登录
  void tryLogout(context) {
    BaseWidget.showLoadingAlert("正在清理数据...", context);
    BossDbProvider.ins().deleteAll().flatMap((value) {
      return ArticleDbProvider.ins().deleteAll();
    }).listen((event) {
      UserConfig.getIns().clear();
      Global.user.setUser(BaseEmpty.emptyUser);

      JpushApi.ins().clearTags();

      BaseTool.toast(msg: "退出成功");
      Get.offAll(() => HomePage());
    });
  }

  ///微信登录回调
  void weChatCallback() {
    fluwx.weChatResponseEventHandler.distinct((a, b) => a == b).listen((resp) {
      if (mounted) {}
      if (resp is fluwx.WeChatAuthResponse) {
        print('wxAuthCode:${resp.code}');
        tryBindWeChat(resp.code);
      }
    });
  }

  ///尝试跳转微信授权
  Future<void> tryJumpWechat() async {
    BaseTool.isWeChatInstalled().then((result) {
      if (result) {
        fluwx
            .sendWeChatAuth(
                scope: "snsapi_userinfo", state: "flutter_boss_says")
            .then((value) {
          print("jumpToWx:$value");
        }).catchError((error) {
          print('jumpToWx:$error');
        });
      } else {
        print('jumpToWx:未安装微信应用');
        BaseTool.toast(msg: "请先下载并安装微信");
      }
    });
  }

  ///尝试绑定微信
  void tryBindWeChat(String code) {
    BaseWidget.showLoadingAlert("正在尝试绑定...", context);

    UserApi.ins().obtainWechatBind(code).listen((event) {
      UserConfig.getIns().token = event.token;
      Global.user.setUser(event.userInfo);

      Get.back();
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "绑定失败");
    });
  }

  ///尝试绑定手机号
  void tryBindPhone() {
    Get.to(() => UserBindPhonePage());
  }

  ///尝试修改手机号
  void tryChangePhone(context) {
    showPhoneName(context, onDismiss: () {
      Get.back();
    }, onConfirm: (phone) {
      if (isInputAvailable(phone)) {
        BaseWidget.showLoadingAlert("正在发送验证码...", context);
        UserApi.ins().obtainSendCode(phone, 1).listen((event) {
          Get.back();
          var data = {"phoneNumber": phone, "rnd": event};
          Get.off(() => UserChangePhonePage(), arguments: data);
        }, onError: (res) {
          Get.back();
          BaseTool.toast(msg: res.msg);
        });
      }
    });
  }

  bool isInputAvailable(String content) {
    if (content.isNullOrEmpty()) {
      BaseTool.toast(msg: "请输入手机号");
      return false;
    }

    if (content[0] != "1") {
      BaseTool.toast(msg: "请输入正确的手机号");
      return false;
    }

    if (content.length != 11) {
      BaseTool.toast(msg: "请输入正确的手机号");
      return false;
    }

    return true;
  }

  ///点击修改
  void onClickChange(index, context) {
    switch (index) {
      case 0:
        showChangeName(context, onDismiss: () {
          Get.back();
        }, onConfirm: (name) {
          tryChangeName(name, context);
        });
        break;
      case 2:
        if (Global.user.user.value.type != BaseEmpty.emptyUser.type &&
            !Global.user.user.value.phone.isNullOrEmpty()) {
          tryChangePhone(context);
        } else {
          tryBindPhone();
        }
        break;
      case 3:
        if (Global.user.user.value.type != BaseEmpty.emptyUser.type &&
            Global.user.user.value.wxName.isNullOrEmpty()) {
          showAskBindDialog(context, onDismiss: () {
            Get.back();
          }, onConfirm: () {
            Get.back();
            tryJumpWechat();
          });
        } else {
          BaseTool.toast(msg: "暂不支持换绑微信");
        }
        break;
    }
  }

  ///点击item
  void onClickItem(index) {
    switch (index) {
      case 0:
        BaseTool.toast(msg: "账号昵称：${Global.user.user.value.nickName}");
        break;
      case 1:
        BaseTool.copyText(Global.user.user.value.id, infix: "账号ID");
        break;
      default:
        break;
    }
  }

  ///尝试修改账户昵称
  void tryChangeName(name, context) {
    UserEntity entity = Global.user.user.value;

    if (entity.nickName != name) {
      BaseWidget.showLoadingAlert("正在更新...", context);
      UserApi.ins().obtainChangeName(name).listen((event) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            ).onClick(() {
              tryLogout(context);
            }),
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
        itemCount: 4,
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
                          ? Global.user.user.value.type ==
                                  BaseEmpty.emptyUser.type
                              ? "请先登录！"
                              : Global.user.user.value.nickName
                          : index == 1
                              ? Global.user.user.value.type ==
                                      BaseEmpty.emptyUser.type
                                  ? "游客：${UserConfig.getIns().tempId.substring(0, 12)}..."
                                  : "ID：${Global.user.user.value.id}"
                              : index == 2
                                  ? Global.user.user.value.type ==
                                          BaseEmpty.emptyUser.type
                                      ? "请先登录！"
                                      : Global.user.user.value.phone
                                              .isNullOrEmpty()
                                          ? "绑定手机号"
                                          : Global.user.user.value.phone
                                              .hidePhoneNumber()
                                  : Global.user.user.value.wxName
                                          .isNullOrEmpty()
                                      ? "绑定微信"
                                      : Global.user.user.value.wxName,
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
                        .marginOn(right: 32)
                        .onClick(() {
                        onClickChange(index, context);
                      }),
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
      onClickItem(index);
    });
  }
}
