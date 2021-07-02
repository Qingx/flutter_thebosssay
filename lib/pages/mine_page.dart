import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/dialog/boss_setting_dialog.dart';
import 'package:flutter_boss_says/pages/input_phone_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  UserController controller;
  List<String> infoNames;
  List<String> itemNames;
  List<String> itemIcons;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    controller = Global.user;

    infoNames = ["追踪数", "收藏数", "今日阅读量"];
    itemNames = [
      "我的收藏",
      "阅读记录",
      "推荐给好友",
      "空白",
      "关于boss说",
      "联系我们",
      "给app评分",
      "清除缓存",
    ];
    itemIcons = [
      R.assetsImgItemFavorite,
      R.assetsImgItemHistory,
      R.assetsImgItemShare,
      "空白",
      R.assetsImgItemAbout,
      R.assetsImgItemContact,
      R.assetsImgItemScore,
      R.assetsImgItemClear,
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onShare() {
    Share.share('https://cn.bing.com', subject: "必应");
  }

  void onSetting(BuildContext context) {
    BaseTool.toast(msg: "账号设置");
  }

  void onClickUser() {
    if (UserConfig.getIns().loginStatus) {
      // UserConfig.getIns().clear();
      // Global.user.setUser(BaseEmpty.emptyUser);

      // UserEntity user = UserEntity()
      //   ..id = "0101010101"
      //   ..wechatName = "花束爱山毛榉";
      //
      // UserConfig.getIns().user = user;
      // Global.user.setUser(user);
    } else {
      BaseTool.toast(msg: "请先登录！");
      Get.to(() => InputPhonePage());
    }
  }

  void onClickInfo(index) {
    BaseTool.toast(msg: infoNames[index]);
  }

  void onClickItem(index) {
    BaseTool.toast(msg: itemNames[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BaseColor.pageBg,
      child: Stack(
        children: [
          topWidget(),
          bodyWidget(),
        ],
      ),
    );
  }

  Widget topBar() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset(R.assetsImgSettingDark, width: 24, height: 24)
              .marginOn(right: 20)
              .onClick(() {
            onSetting(context);
          }),
          Image.asset(R.assetsImgShareDark, width: 24, height: 24)
              .marginOn(right: 16)
              .onClick(onShare),
        ],
      ),
    );
  }

  Widget topWidget() {
    return Container(
      height: 176 + MediaQuery.of(context).padding.top,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(R.assetsImgTestSplash),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(12),
            bottomEnd: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget bodyWidget() {
    return Container(
      child: Column(
        children: [
          topBar(),
          idWidget(),
          infoWidget(),
          Expanded(child: listWidget()),
        ],
      ),
    );
  }

  Widget idWidget() {
    return Container(
      height: 88,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.user.value == BaseEmpty.emptyUser
                        ? "请先登录！"
                        : controller.user.value.wechatName,
                    style: TextStyle(
                        fontSize: 28,
                        color: BaseColor.textDark,
                        fontWeight: FontWeight.bold),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.user.value == BaseEmpty.emptyUser
                        ? "游客：123123123"
                        : "ID：${controller.user.value.id}",
                    style: TextStyle(fontSize: 16, color: BaseColor.textGray),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: BaseColor.textDark,
            ),
          ).onClick(onClickUser),
        ],
      ),
    );
  }

  Widget infoWidget() {
    return Container(
      height: 88,
      margin: EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(child: infoItemWidget(0)),
          Container(
            width: 1,
            margin: EdgeInsets.only(top: 20, bottom: 20),
            color: BaseColor.line,
          ),
          Expanded(child: infoItemWidget(1)),
          Container(
            width: 1,
            margin: EdgeInsets.only(top: 20, bottom: 20),
            color: BaseColor.line,
          ),
          Expanded(child: infoItemWidget(2)),
        ],
      ),
    );
  }

  Widget infoItemWidget(int index) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            index.toString(),
            style: TextStyle(
                fontSize: 18,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            infoNames[index],
            style: TextStyle(fontSize: 12, color: BaseColor.textGray),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).onClick(() {
      onClickInfo(index);
    });
  }

  Widget listWidget() {
    return MediaQuery.removePadding(
      removeBottom: true,
      removeTop: true,
      context: context,
      child: ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          if (index == 3) {
            return Container(height: 8, color: BaseColor.loadBg);
          } else
            return listItemWidget(index);
        },
        itemCount: itemNames.length,
      ),
    );
  }

  Widget listItemWidget(index) {
    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 24 : 0),
      padding: EdgeInsets.only(left: 16, right: 24),
      color: BaseColor.pageBg,
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            itemIcons[index],
            width: 28,
            height: 28,
            fit: BoxFit.cover,
          ),
          Text(
            itemNames[index],
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ).marginOn(left: 12),
          Expanded(
            child: index == 0 && controller.user.value == BaseEmpty.emptyUser
                ? Container(
                    padding: EdgeInsets.only(right: 4),
                    alignment: Alignment.centerRight,
                    child: Text(
                      "请先登录",
                      style: TextStyle(fontSize: 16, color: BaseColor.textGray),
                      softWrap: false,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : SizedBox(),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: BaseColor.textGray,
          ),
        ],
      ),
    ).onClick(() {
      onClickItem(index);
    });
  }
}
