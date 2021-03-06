import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/cache/cache_provider.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/event/boss_batch_tack_event.dart';
import 'package:flutter_boss_says/event/boss_tack_event.dart';
import 'package:flutter_boss_says/event/on_top_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/pages/home_boss_all_page.dart';
import 'package:flutter_boss_says/pages/search_boss_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class HomeBossContentPage extends StatefulWidget {
  HomeBossContentPage({Key key}) : super(key: key);

  @override
  _HomeBossContentPageState createState() => _HomeBossContentPageState();
}

class _HomeBossContentPageState extends State<HomeBossContentPage>
    with AutomaticKeepAliveClientMixin {
  var tackDispose;
  var tackBatchDispose;
  var eventTopDispose;
  var eventScrollDispose;

  var builderFuture;
  List<BossLabelEntity> mLabels;
  String mCurrentLabel;

  ScrollController scrollController;
  EasyRefreshController controller;

  List<BossSimpleEntity> mData = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();

    tackDispose?.cancel();
    tackBatchDispose?.cancel();
    eventTopDispose?.cancel();
    eventScrollDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    mLabels = [];
    mCurrentLabel = "-1";

    builderFuture = initData();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  ///eventBus
  void eventBus() {
    tackDispose = Global.eventBus.on<BossTackEvent>().listen((event) {
      if (event.labels.contains(mCurrentLabel) || mCurrentLabel == "-1") {
        mData = CacheProvider.getIns().getBossByLabel(mCurrentLabel);
        setState(() {});
      }
    });

    tackBatchDispose = Global.eventBus.on<BossBatchTackEvent>().listen((event) {
      mData = CacheProvider.getIns().getBossByLabel(mCurrentLabel);
      setState(() {});
    });

    eventTopDispose = Global.eventBus.on<TopOrCancelEvent>().listen((event) {
      if (event.doTop) {
        doAddTop(event.id);
      } else {
        doCancelTop(event.id);
      }
    });
  }

  ///?????????????????????
  Future<bool> initData() {
    mLabels = CacheProvider.getIns().getAllLabel();
    mData = CacheProvider.getIns().getBossByLabel(mCurrentLabel);
    return Observable.just(!mLabels.isLabelEmpty()).last;
  }

  ///?????????????????????
  Future<bool> errorLoadData() {
    return AppApi.ins().obtainGetLabelList().onErrorReturn([]).flatMap((value) {
      CacheProvider.getIns().insertLabelList(value);

      value = [BaseEmpty.emptyLabel, ...value];
      mLabels = value;

      return AppApi.ins().obtainGetAllFollowBoss("-1");
    }).onErrorReturn([]).flatMap((value) {
      CacheProvider.getIns().insertBossList(value);

      if (mCurrentLabel != "-1") {
        value = value
            .where(
              (element) => element.labels.contains(mCurrentLabel),
            )
            .toList();
      }

      value.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

      mData = value;

      return Observable.just(!mLabels.isLabelEmpty());
    }).last;
  }

  ///????????????
  void loadData() {
    AppApi.ins().obtainGetAllFollowBoss("-1").onErrorReturn([]).listen((value) {
      CacheProvider.getIns().insertBossList(value);

      if (mCurrentLabel != "-1") {
        value = value
            .where(
              (element) => element.labels.contains(mCurrentLabel),
            )
            .toList();
      }
      value.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

      mData = value;
      controller.finishRefresh(success: true);
      setState(() {});
    }, onError: (res) {
      controller.finishRefresh(success: false);
    });
  }

  void onClickTab(BossLabelEntity entity) {
    if (entity.id != mCurrentLabel) {
      mCurrentLabel = entity.id;

      mData = CacheProvider.getIns().getBossByLabel(mCurrentLabel);
      setState(() {});
    }
  }

  void onSearchClick() {
    Get.to(() => SearchBossPage());
  }

  ///??????
  void doAddTop(String id) {
    var index = mData.indexWhere((element) => element.id == id);
    if (index != -1) {
      AppApi.ins().obtainBossTopOrMove(id, true).listen((event) {
        var entity = mData[index];
        entity.top = true;
        CacheProvider.getIns().updateBoss(entity);
        mData.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

        setState(() {});

        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        );
      }, onError: (res) {
        BaseTool.toast(msg: "????????????");
      });
    }
  }

  ///????????????
  void doCancelTop(String id) {
    var index = mData.indexWhere((element) => element.id == id);
    if (index != -1) {
      AppApi.ins().obtainBossTopOrMove(id, false).listen((event) {
        var entity = mData[index];
        entity.top = false;
        CacheProvider.getIns().updateBoss(entity);

        mData.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

        setState(() {});
      }, onError: (res) {
        BaseTool.toast(msg: "????????????");
      });
    }
  }

  ///????????????
  void doCancelFollow(BossSimpleEntity entity) {
    var index = mData.indexWhere((element) => element.id == entity.id);
    if (index != -1) {
      showFollowAskCancelDialog(context, onDismiss: () {
        Get.back();
      }, onConfirm: () {
        BaseWidget.showLoadingAlert("????????????...", context);

        AppApi.ins().obtainCancelFollowBoss(entity.id).listen((event) {
          Get.back();
          Get.back();
          CacheProvider.getIns().deleteBoss(entity.id);
          mData.removeAt(index);
          mData.sort((a, b) => (b.getSort()).compareTo(a.getSort()));

          BaseWidget.showDoFollowChangeDialog(context, false);

          UserEntity userEntity = Global.user.user.value;
          userEntity.traceNum--;
          Global.user.setUser(userEntity);

          Global.eventBus.fire(
            BossTackEvent(
              id: entity.id,
              isFollow: false,
              labels: entity.labels,
            ),
          );

          JpushApi.ins().deleteTags([entity.id]);

          setState(() {});
        }, onError: (res) {
          Get.back();
          BaseTool.toast(msg: "????????????,${res.msg}");
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data) {
        return contentWidget();
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = errorLoadData();
          setState(() {});
        });
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        children: [
          BaseWidget.statusBar(context, true),
          titleTabBar(),
          tabWidget(),
          Expanded(
            child: Stack(
              children: [
                refreshWidget().positionOn(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                ),
                floatWidget().positionOn(right: 16, bottom: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget titleTabBar() {
    return Container(
      alignment: Alignment.bottomLeft,
      color: BaseColor.pageBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          titleWidget().marginOn(left: 16),
          Expanded(child: SizedBox()),
          Image.asset(
            R.assetsImgSearch,
            width: 20,
            height: 20,
          ).onClick(onSearchClick).marginOn(right: 16, bottom: 8)
        ],
      ),
    );
  }

  Widget titleWidget() {
    return Text(
      "????????????",
      style: TextStyle(
        fontSize: 28,
        color: BaseColor.textDark,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget tabWidget() {
    return Container(
      height: 52,
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(mLabels[index], index);
          },
          itemCount: mLabels.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    bool hasSelect = mCurrentLabel == entity.id;

    Color bgColor = hasSelect ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = hasSelect ? Colors.white : BaseColor.accent;

    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          entity.name,
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      onClickTab(entity);
    });
  }

  Widget floatWidget() {
    return Container(
      alignment: Alignment.center,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BaseColor.accent,
        boxShadow: [
          BoxShadow(
              color: BaseColor.accentShadow,
              offset: Offset(0.0, 4.0), //??????x,y????????????
              blurRadius: 4, //??????????????????
              spreadRadius: 0 //??????????????????
              )
        ],
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
    ).onClick(() {
      Get.to(() => HomeBossAllPage());
    });
  }

  Widget refreshWidget() {
    return BaseWidget.refreshWidget(
      slivers: [bodyWidget()],
      controller: controller,
      scrollController: scrollController,
      loadData: loadData,
    );
  }

  Widget bodyWidget() {
    return mData.isNullOrEmpty()
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return emptyBodyWidget();
              },
              childCount: 1,
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return bodyItemWidget(mData[index], index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget bodyItemWidget(BossSimpleEntity entity, int index) {
    Color bgColor = entity.top ? BaseColor.accentLight : BaseColor.pageBg;

    return Slidable(
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
        height: 80,
        color: bgColor,
        child: Row(
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                entity.name,
                                style: TextStyle(
                                    color: BaseColor.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).marginOn(left: 8),
                              Expanded(
                                child: Container(
                                  height: 16,
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeBottom: true,
                                    removeTop: true,
                                    removeLeft: true,
                                    removeRight: true,
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          HttpConfig.fullUrl(
                                            entity.photoUrl[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ).marginOn(left: index == 0 ? 8 : 1);
                                      },
                                      itemCount:
                                          entity?.photoUrl?.isNullOrEmpty()
                                              ? 0
                                              : entity?.photoUrl?.length >= 3
                                                  ? 2
                                                  : entity?.photoUrl?.length,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          BaseTool.getBossItemTime(entity.updateTime),
                          style: TextStyle(
                              fontSize: 12, color: BaseColor.textDarkLight),
                          textAlign: TextAlign.end,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    entity.role,
                    style:
                        TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(left: 8),
                ],
              ),
            ),
          ],
        ),
      ).onClick(() {
        Get.to(() => BossHomePage(), arguments: entity.id);
      }),
      actionPane: SlidableScrollActionPane(),
      key: Key(entity.id),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: entity.top ? "????????????" : "??????",
          color: BaseColor.accent,
          icon: entity.top
              ? Icons.vertical_align_bottom
              : Icons.vertical_align_top,
          closeOnTap: true,
          onTap: () {
            var index = mData.indexWhere((element) => element.id == entity.id);
            if (index != -1) {
              Global.eventBus
                  .fire(TopOrCancelEvent(id: entity.id, doTop: !entity.top));
            }
          },
        ),
        IconSlideAction(
          caption: '????????????',
          color: Colors.red,
          icon: Icons.delete,
          closeOnTap: true,
          onTap: () {
            doCancelFollow(entity);
          },
        ),
      ],
    );
  }

  Widget emptyBodyWidget() {
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        176;

    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              R.assetsImgEmptyBoss,
              width: 134,
              height: 108,
              fit: BoxFit.cover,
            ),
            Text(
              "?????????????????????????????????\n?????????+????????????",
              style: TextStyle(color: BaseColor.textGray, fontSize: 16),
              textAlign: TextAlign.center,
            ).marginOn(top: 24),
            Image.asset(
              R.assetsImgEmptyLine,
              width: 124,
              height: 174,
              fit: BoxFit.cover,
            ).marginOn(top: 16, left: 32),
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
      loadData();
    });
  }

  Widget loadingWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(0.2, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.6, 8),
          loadingItemWidget(0.4, 8),
        ],
      ),
    );
  }

  Widget loadingItemWidget(double width, double margin) {
    return Container(
      width: (MediaQuery.of(context).size.width - 32) * width,
      height: 16,
      margin: EdgeInsets.only(left: 16, right: 16, top: margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: BaseColor.loadBg,
      ),
    );
  }
}
