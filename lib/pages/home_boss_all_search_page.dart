import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/event/refresh_search_boss_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class HomeBossAllSearchPage extends StatefulWidget {
  String searchText = "";

  HomeBossAllSearchPage({Key key}) : super(key: key);

  @override
  _HomeBossAllSearchPageState createState() => _HomeBossAllSearchPageState();
}

class _HomeBossAllSearchPageState extends State<HomeBossAllSearchPage>
    with AutomaticKeepAliveClientMixin {
  var builderFuture;

  bool hasData = false;
  List<BossInfoEntity> mData;

  ScrollController scrollController;
  EasyRefreshController controller;

  var searchDispose;

  @override
  bool get wantKeepAlive => false;

  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
    controller?.dispose();

    searchDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    hasData = false;
    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  void eventBus() {
    searchDispose =
        Global.eventBus.on<RefreshSearchBossEvent>().listen((event) {
      builderFuture = loadInitData();
      setState(() {});
    });
  }

  Future<List<BossInfoEntity>> loadInitData() {
    return BossApi.ins()
        .obtainAllBossSearchList(widget.searchText)
        .doOnData((event) {
      mData = event;
    }).last;
  }

  void onFollowChanged(BossInfoEntity entity) {
    if (entity.isCollect) {
      cancelFollow(entity);
    } else {
      doFollow(entity);
    }
  }

  void cancelFollow(BossInfoEntity entity) {
    showFollowAskCancelDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: () {
      BaseWidget.showLoadingAlert("尝试取消...", context);

      BossApi.ins().obtainNoFollowBoss(entity.id).listen((event) {
        Get.back();
        Get.back();

        BaseWidget.showDoFollowChangeDialog(context, false);

        entity.isCollect = false;
        setState(() {});

        UserEntity userEntity = Global.user.user.value;
        userEntity.traceNum--;
        Global.user.setUser(userEntity);

        Global.eventBus
            .fire(RefreshFollowEvent(id: entity.id, isFollow: false));

        JpushApi.ins().deleteTags([entity.id]);
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: " 取消失败，${res.msg}");
      });
    });
  }

  void doFollow(BossInfoEntity entity) {
    BaseWidget.showLoadingAlert("尝试追踪...", context);
    BossApi.ins().obtainFollowBoss(entity.id).listen((event) {
      Get.back();

      entity.isCollect = true;
      setState(() {});

      UserEntity userEntity = Global.user.user.value;
      userEntity.traceNum++;
      Global.user.setUser(userEntity);

      Global.eventBus.fire(RefreshFollowEvent(id: entity.id, isFollow: true));

      showAskPushDialog(context, onConfirm: () {
        Get.back();

        JpushApi.ins().addTags([entity.id]);
        BaseWidget.showDoFollowChangeDialog(context, true);
      }, onDismiss: () {
        Get.back();

        BaseWidget.showDoFollowChangeDialog(context, true);
      });
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: " 追踪失败，${res.msg}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BossInfoEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(
      BuildContext context, AsyncSnapshot<List<BossInfoEntity>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return mData.isNullOrEmpty()
        ? searchEmptyWidget()
        : Container(
            child: Column(
              children: [
                searchTitleWidget(),
                Expanded(child: searchResultWidget()),
              ],
            ),
          );
  }

  Widget searchTitleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 40,
      child: RichText(
        text: TextSpan(
          text: "共找到",
          style: TextStyle(
              color: BaseColor.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: "${mData.length ?? 0}",
              style: TextStyle(
                  color: BaseColor.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: "条相关",
              style: TextStyle(
                  color: BaseColor.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ).marginOn(left: 16),
    );
  }

  Widget searchResultWidget() {
    return Container(
      color: BaseColor.loadBg,
      padding: EdgeInsets.only(top: 2),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 4 / 7,
          ),
          itemBuilder: (context, index) {
            return searchItemWidget(mData[index], index);
          },
          itemCount: mData.length,
        ),
      ),
    );
  }

  Widget searchItemWidget(BossInfoEntity entity, int index) {
    Color labelColor = entity.isCollect ? BaseColor.loadBg : BaseColor.accent;
    String label = entity.isCollect
        ? R.assetsImgBossOrderSelect
        : R.assetsImgBossOrderNormal;

    return Container(
      color: BaseColor.pageBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.network(
              HttpConfig.fullUrl(entity.head),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  R.assetsImgDefaultHead,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Text(
            entity.name,
            style: TextStyle(
                fontSize: 14,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ).marginOn(top: 8),
          Container(
            width: 64,
            alignment: Alignment.center,
            child: Text(
              entity.role,
              style: TextStyle(fontSize: 10, color: BaseColor.textGray),
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 56,
            height: 24,
            margin: EdgeInsets.only(top: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Image.asset(
              label,
              width: 15,
              height: 15,
            ),
          ).onClick(() {
            onFollowChanged(entity);
          }),
        ],
      ),
    ).onClick(() {
      Get.to(() => BossHomePage(), arguments: entity.id);
    });
  }

  Widget searchEmptyWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            R.assetsImgEmptySearch,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          Text(
            "暂无筛选结果",
            style: TextStyle(color: BaseColor.textGray, fontSize: 16),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
