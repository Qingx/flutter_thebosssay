import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/config/user_controller.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/jump_boss_event.dart';
import 'package:flutter_boss_says/pages/mine_about_app_page.dart';
import 'package:flutter_boss_says/pages/mine_change_user_page.dart';
import 'package:flutter_boss_says/pages/mine_collect_page.dart';
import 'package:flutter_boss_says/pages/mine_contact_author_page.dart';
import 'package:flutter_boss_says/pages/mine_history_all_page.dart';
import 'package:flutter_boss_says/pages/mine_history_today_page.dart';
import 'package:flutter_boss_says/pages/mine_point_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/test/test_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class HomeMinePage extends StatefulWidget {
  const HomeMinePage({Key key}) : super(key: key);

  @override
  _HomeMinePageState createState() => _HomeMinePageState();
}

class _HomeMinePageState extends State<HomeMinePage>
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

    infoNames = ["??????", "??????", "??????", "????????????"];
    itemNames = [
      "????????????",
      "????????????",
      "???????????????",
      "??????",
      "??????boss???",
      "????????????",
      "???app??????",
      // "????????????",
    ];
    itemIcons = [
      R.assetsImgItemFavorite,
      R.assetsImgItemHistory,
      R.assetsImgItemShare,
      "??????",
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

  ///?????? ????????????????????? tab??????????????????
  void onShare() {
    showShareDialog(context, false, onDismiss: () {
      Get.back();
    }, doClick: (index) {
      switch (index) {
        case 0:
          BaseTool.shareToSession();
          break;
        case 1:
          BaseTool.shareToTimeline();
          break;
        default:
          BaseTool.shareCopyLink();
          break;
      }
    });
  }

  ///?????????????????? ????????????????????? ???????????????
  void onClickUser() {
    if (UserConfig.getIns().loginStatus) {
      Get.to(() => MineChangeUserPage());
    } else {
      BaseTool.jumpLogin(context);
    }
  }

  ///????????????-????????? ?????? ?????? ?????? ????????????
  void onClickInfo(index) {
    switch (index) {
      case 0:
        Global.eventBus.fire(BaseEvent(JumpBossEvent));
        break;
      case 1:
        onClickFavorite();
        break;
      case 2:
        onClickPoint();
        break;
      case 3:
        onClickTodayHistory();
        break;
    }
  }

  ///????????????/?????????
  void onClickFavorite() {
    if (UserConfig.getIns().loginStatus) {
      Get.to(() => MineCollectPage());
    } else {
      BaseTool.toast(msg: "???????????????");
      BaseTool.jumpLogin(context);
    }
  }

  ///??????????????????
  void onClickHistory() {
    if (UserConfig.getIns().loginStatus) {
      Get.to(() => MineHistoryAllPage());
    } else {
      BaseTool.toast(msg: "???????????????");
      BaseTool.jumpLogin(context);
    }
  }

  ///??????????????????
  void onClickPoint() {
    if (UserConfig.getIns().loginStatus) {
      Get.to(() => MinePointPage());
    } else {
      BaseTool.toast(msg: "???????????????");
      BaseTool.jumpLogin(context);
    }
  }

  ///???????????? tab?????? ???????????? ???????????? ??????????????? ??????boss??? ???????????? ???app??????
  void onClickItem(index) {
    switch (index) {
      case 0:
        onClickFavorite();
        break;
      case 1:
        onClickHistory();
        break;
      case 2:
        onShare();
        break;
      case 4:
        Get.to(() => MineAboutAppPage());
        break;
      case 5:
        Get.to(() => ContactAuthorPage());
        break;
      case 6:
        showStore();
        // doTest();
        break;
      case 7:
        onClickClear();
        break;
      default:
        BaseTool.toast(msg: itemNames[index]);
        break;
    }
  }

  ///??????????????????
  void onClickTodayHistory() {
    Get.to(() => MineHistoryTodayPage());
  }

  ///??????????????????????????????
  @Deprecated("????????????tab?????????")
  void onClickClear() {
    BaseWidget.showLoadingAlert("??????????????????...", context);
    Observable.just(true).delay(Duration(milliseconds: 500)).listen((event) {
      BaseTool.toast(msg: "????????????");
      FlutterAppBadger.updateBadgeCount(0);
      CacheProvider.getIns().clearAll();
      Get.back();
    });
  }

  ///app??????
  void showStore() {
    const MethodChannel channel =
        const MethodChannel('app.storescore/storescore');
    channel.invokeMethod("storeScore");
  }

  ///???????????? ??????????????????????????????
  void doTest() {
    Get.to(() => TestPage());
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
              .onClick(onClickUser),
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
          image: AssetImage(R.assetsImgMineTopBg),
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
                    controller.user.value.type == BaseEmpty.emptyUser.type
                        ? "???????????????"
                        : controller.user.value.nickName,
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
                    controller.user.value.type == BaseEmpty.emptyUser.type
                        ? "?????????${UserConfig.getIns().tempId.substring(0, 12)}..."
                        : "ID???${controller.user.value.id}",
                    style:
                        TextStyle(fontSize: 16, color: BaseColor.textDarkLight),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
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
          Container(
            width: 1,
            margin: EdgeInsets.only(top: 20, bottom: 20),
            color: BaseColor.line,
          ),
          Expanded(child: infoItemWidget(3)),
        ],
      ),
    );
  }

  Widget infoItemWidget(int index) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Text(
              index == 0
                  ? Global.user.user.value.traceNum.toString()
                  : index == 1
                      ? Global.user.user.value.collectNum.toString()
                      : index == 2
                          ? Global.user.user.value.pointNum.toString()
                          : Global.user.user.value.readNum.toString(),
              style: TextStyle(
                  fontSize: 24,
                  color: BaseColor.textDark,
                  fontWeight: FontWeight.bold),
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            infoNames[index],
            style: TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
            softWrap: false,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ).marginOn(top: 4),
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
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          if (index == 3) {
            return Container(height: 8, color: BaseColor.mineBg);
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
            child: index == 0 &&
                    controller.user.value.type == BaseEmpty.emptyUser.type
                ? Container(
                    padding: EdgeInsets.only(right: 4),
                    alignment: Alignment.centerRight,
                    child: Text(
                      "????????????",
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
