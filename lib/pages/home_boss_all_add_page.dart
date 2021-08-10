import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/operation_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class HomeBossAllAddPage extends StatefulWidget {
  const HomeBossAllAddPage({Key key}) : super(key: key);

  @override
  _HomeBossAllAddPageState createState() => _HomeBossAllAddPageState();
}

class _HomeBossAllAddPageState extends State<HomeBossAllAddPage>
    with AutomaticKeepAliveClientMixin {
  var builderFuture;

  String mCurrentTab;
  List<BossLabelEntity> mLabels;
  List<BossInfoEntity> mData;
  OperationEntity operationEntity;
  bool isBatch; //是否开启批量追踪
  List<String> mSelectList; //选中的boss

  var eventDispose;

  ScrollController scrollController;
  EasyRefreshController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
    controller?.dispose();
    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();

    mCurrentTab = BaseEmpty.emptyLabel.id;
    mLabels = DataConfig.getIns().bossLabels;
    mData = [];
    isBatch = false;
    mSelectList = [];

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<RefreshFollowEvent>().listen((event) {
      var index = mData.indexWhere((element) => element.id == event.id);
      if (index != null) {
        mData[index].isCollect = event.isFollow;
        setState(() {});
      }
    });
  }

  Future<List<BossInfoEntity>> loadInitData() {
    return UserApi.ins().obtainOperationPhoto().flatMap((value) {
      operationEntity = value;

      return BossApi.ins().obtainAllBossList();
    }).doOnData((event) {
      mData = event;
    }).last;
  }

  void loadData() {
    UserApi.ins().obtainOperationPhoto().flatMap((value) {
      operationEntity = value;

      return BossApi.ins().obtainAllBossList();
    }).listen((event) {
      mData = event;

      setState(() {});

      controller.finishRefresh(success: true);
    }, onError: (res) {
      controller.finishRefresh(success: false);
    });
  }

  void onItemClick(BossInfoEntity entity) {
    if (isBatch) {
      if (mSelectList.contains(entity.id)) {
        mSelectList.remove(entity.id);
      } else {
        mSelectList.add(entity.id);
      }
      setState(() {});
    } else {
      Get.to(() => BossHomePage(), arguments: entity);
    }
  }

  void onFollowChanged(BossInfoEntity entity) {
    if (!isBatch) {
      if (entity.isCollect) {
        cancelFollow(entity);
      } else {
        doFollow(entity);
      }
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

  void doBatchTack() {
    if (!mSelectList.isNullOrEmpty()) {
      BaseWidget.showLoadingAlert("尝试批量追踪...", context);

      BossApi.ins().obtainGuideFollowList(mSelectList).listen((event) {
        Get.back();

        List<BossInfoEntity> select =
            mData.where((element) => mSelectList.contains(element.id)).toList();
        List.generate(select.length, (index) => select[index].isCollect = true);
        setState(() {});

        UserEntity userEntity = Global.user.user.value;
        userEntity.traceNum += select.length;
        Global.user.setUser(userEntity);

        Global.eventBus.fire(RefreshFollowEvent(needLoading: true));

        showAskPushDialog(context, isBatch: true, onConfirm: () {
          Get.back();

          JpushApi.ins().addTags(mSelectList);

          isBatch = false;
          mSelectList = [];
          setState(() {});

          BaseWidget.showDoFollowChangeDialog(context, true);
        }, onDismiss: () {
          Get.back();

          BaseWidget.showDoFollowChangeDialog(context, true);
        });
      }, onError: (res) {
        BaseTool.toast(msg: "追踪失败，${res.msg}");
      });
    } else {
      BaseTool.toast(msg: "请至少选择一位Boss");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          typeWidget(),
          Expanded(
            child: bodyWidget(),
          ),
        ],
      ),
    );
  }

  Widget typeWidget() {
    return Container(
      width: 100,
      color: BaseColor.loadBg,
      child: Column(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              removeBottom: true,
              removeTop: true,
              context: context,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return typeItemWidget(mLabels[index], index);
                },
                itemCount: mLabels.length,
              ),
            ),
          ),
          batchTackWidget(),
        ],
      ),
    );
  }

  Widget typeItemWidget(BossLabelEntity entity, int index) {
    bool hasSelect = mCurrentTab == entity.id;
    Color color = hasSelect ? BaseColor.pageBg : BaseColor.loadBg;

    return hasSelect
        ? Container(
            width: 100,
            height: 72,
            alignment: Alignment.center,
            color: color,
            child: Container(
              width: 80,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: BaseColor.accent,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Text(
                entity.name,
                style: TextStyle(color: Colors.white, fontSize: 14),
                softWrap: false,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ).onClick(() {
            scrollController.animateTo(
              scrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 480),
              curve: Curves.ease,
            );
          })
        : Container(
            width: 80,
            height: 64,
            alignment: Alignment.center,
            color: color,
            child: Text(
              entity.name,
              style: TextStyle(
                color: BaseColor.textGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ).onClick(() {
            mCurrentTab = mLabels[index].id;
            setState(() {});

            scrollController.animateTo(
              scrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 480),
              curve: Curves.ease,
            );
          });
  }

  Widget batchTackWidget() {
    return isBatch
        ? Container(
            width: 100,
            color: BaseColor.loadBg,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 32,
                  margin: EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: BaseColor.accent,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Text(
                    "批量追踪",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 100,
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "确定",
                    style: TextStyle(color: BaseColor.accent, fontSize: 14),
                  ),
                ).onClick(doBatchTack),
                Container(
                  width: 100,
                  padding: EdgeInsets.only(top: 8, bottom: 40),
                  alignment: Alignment.center,
                  child: Text(
                    "取消",
                    style: TextStyle(color: BaseColor.textDark, fontSize: 14),
                  ),
                ).onClick(() {
                  isBatch = false;
                  mSelectList = [];
                  setState(() {});
                })
              ],
            ),
          )
        : Container(
            width: 100,
            height: 64,
            margin: EdgeInsets.only(bottom: 24),
            alignment: Alignment.center,
            color: BaseColor.loadBg,
            child: Text(
              "批量追踪",
              style: TextStyle(
                color: BaseColor.accent,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ).onClick(() {
            isBatch = true;
            setState(() {});
          });
  }

  Widget bodyWidget() {
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
    return BaseWidget.refreshWidget(
      slivers: [operationWidget(), bossWidget()],
      controller: controller,
      scrollController: scrollController,
      loadData: loadData,
    );
  }

  Widget operationWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Image.network(
            HttpConfig.fullUrl(operationEntity?.pictureLocation ?? ""),
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                R.assetsImgTestBanner,
                height: 100,
                fit: BoxFit.cover,
              );
            },
          ).marginOn(bottom: 16, left: 16, right: 16).onClick(() {
            Get.to(() => BossHomePage(), arguments: operationEntity.entity);
          });
        },
        childCount: 1,
      ),
    );
  }

  Widget bossWidget() {
    var bossList = mCurrentTab == BaseEmpty.emptyLabel.id
        ? mData
        : mData
            .where((element) => element.labels.contains(mCurrentTab))
            .toList();

    return bossList.isNullOrEmpty()
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return emptyBossWidget();
              },
              childCount: 1,
            ),
          )
        : SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return bossItemWidget(bossList[index]).onClick(() {
                  onItemClick(bossList[index]);
                });
              },
              childCount: bossList.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 4 / 7,
            ),
          );
  }

  Widget bossItemWidget(BossInfoEntity entity) {
    return entity.isCollect
        ? normalItemWidget(entity)
        : isBatch
            ? batchItemWidget(entity)
            : normalItemWidget(entity);
  }

  Widget normalItemWidget(BossInfoEntity entity) {
    Color labelColor = entity.isCollect ? BaseColor.loadBg : BaseColor.accent;
    String label = entity.isCollect
        ? R.assetsImgBossOrderSelect
        : R.assetsImgBossOrderNormal;

    return Container(
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
    );
  }

  Widget batchItemWidget(BossInfoEntity entity) {
    bool isSelect = mSelectList.contains(entity.id);

    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 56,
          child: Stack(
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
              ).positionOn(top: 0, bottom: 0, right: 4, left: 4),
              Icon(
                isSelect ? Icons.check_circle : Icons.radio_button_unchecked,
                color: BaseColor.accent,
                size: 20,
              ).positionOn(top: 0, right: 0),
            ],
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
            color: BaseColor.accent,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Image.asset(
            R.assetsImgBossOrderNormal,
            width: 15,
            height: 15,
          ),
        ),
      ],
    ));
  }

  Widget emptyBossWidget() {
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        172;
    return Container(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            R.assetsImgEmptySearch,
            width: 192,
            height: 192,
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
    ).onClick(() {
      controller.callRefresh();
    });
  }
}
