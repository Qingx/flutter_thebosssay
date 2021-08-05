import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/entity/operation_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/jpush_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/follow_ask_cancel_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_ask_push_dialog.dart';
import 'package:flutter_boss_says/dialog/follow_changed_dialog.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class HomeBossAllPage extends StatefulWidget {
  const HomeBossAllPage({Key key}) : super(key: key);

  @override
  _HomeBossAllPageState createState() => _HomeBossAllPageState();
}

class _HomeBossAllPageState extends State<HomeBossAllPage>
    with BasePageController {
  TextEditingController editingController;

  var builderFuture;
  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = false;
  List<BossLabelEntity> labels = DataConfig.getIns().bossLabels;
  OperationEntity operationEntity;

  String mCurrentTab;

  //0:首页界面 1:搜索结果页面
  int widgetStatus = 0;

  var eventDispose;

  String searchText;

  @override
  void dispose() {
    super.dispose();

    editingController?.dispose();
    controller?.dispose();
    scrollController?.dispose();
    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    eventBus();

    editingController = TextEditingController();

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  Future<WlPage.Page<BossInfoEntity>> loadInitData() {
    pageParam?.reset();
    mCurrentTab = labels[0].id;
    return UserApi.ins().obtainOperationPhoto().flatMap((value) {
      operationEntity = value;

      return BossApi.ins()
          .obtainAllBossList(pageParam, mCurrentTab)
          .doOnData((event) {
        hasData = event.hasData;
        concat(event.records, false);
      });
    }).doOnError((e) {
      print(e);
    }).last;
  }

  Future<WlPage.Page<BossInfoEntity>> loadSearchData(searchText) {
    pageParam?.reset();
    return BossApi.ins()
        .obtainSearchBossList(pageParam, searchText)
        .doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).doOnError((e) {
      print(e);
    }).last;
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

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainAllBossList(pageParam, mCurrentTab).listen((event) {
      hasData = true;
      concat(event.records, loadMore);
      setState(() {});

      if (loadMore) {
        controller.finishLoad(success: true);
      } else {
        controller.finishRefresh(success: true);
      }
    }, onError: (res) {
      if (loadMore) {
        controller.finishLoad(success: false);
      } else {
        controller.finishRefresh(success: false);
      }
    });
  }

  void onEditCleared() {
    if (!editingController.text.isNullOrEmpty()) {
      searchText = "";
      editingController.clear();
      widgetStatus = 0;
      builderFuture = loadInitData();
      setState(() {});
    }
  }

  void onEditSubmitted(String text) {
    if (text.isNullOrEmpty()) {
      searchText = "";
      editingController.clear();
      widgetStatus = 0;
      builderFuture = loadInitData();
      setState(() {});
    } else {
      widgetStatus = 1;
      searchText = text;
      builderFuture = loadSearchData(text);
      setState(() {});
    }
  }

  void onEditChanged(text) {
    print('onEditChanged');
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

      JpushApi.ins().addTags([entity.id]);

      showAskPushDialog(context, onConfirm: () {
        Get.back();

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BaseColor.pageBg,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            topWidget(),
            Expanded(child: bodyWidget()),
          ],
        ),
      ),
    );
  }

  Widget topWidget() {
    return Container(
      height: 56,
      padding: EdgeInsets.only(top: 4, bottom: 12, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: BaseColor.textDark,
            size: 28,
          ).onClick(() {
            Get.back();
          }),
          Expanded(
            child: Obx(() => TextField(
                  controller: editingController,
                  cursorColor: BaseColor.accent,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  autofocus: false,
                  style: TextStyle(fontSize: 16, color: BaseColor.textDark),
                  decoration: InputDecoration(
                    hintText: Global.hint.hint.value == "-1"
                        ? "请输入内容"
                        : Global.hint.hint.value,
                    hintStyle:
                        TextStyle(fontSize: 16, color: BaseColor.textGray),
                    fillColor: BaseColor.loadBg,
                    filled: true,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    suffixIcon: Icon(
                      Icons.cancel,
                      size: 20,
                      color: BaseColor.textGray,
                    ).onClick(onEditCleared),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                      color: BaseColor.textDark,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: onEditChanged,
                  onSubmitted: onEditSubmitted,
                )).marginOn(left: 20),
          ),
          Container(
            height: 56,
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.center,
            child: Text(
              "搜索",
              style: TextStyle(
                color: BaseColor.accent,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ).onClick(() {
            onEditSubmitted(editingController.text);
          })
        ],
      ),
    );
  }

  Widget bodyWidget() {
    return FutureBuilder<WlPage.Page<BossInfoEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context,
      AsyncSnapshot<WlPage.Page<BossInfoEntity>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      print('data:${snapshot.data}');
      if (snapshot.hasData) {
        if (widgetStatus == 0) {
          return contentWidget();
        } else {
          return searchWidget();
        }
      } else
        return BaseWidget.errorWidget(() {
          loadData(false);
        });
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      child: Row(
        children: [
          typeWidget(),
          Expanded(
            child: BaseWidget.refreshWidgetPage(
              slivers: [operationWidget(), bossWidget()],
              controller: controller,
              scrollController: scrollController,
              hasData: hasData,
              loadData: loadData,
            ).paddingOnly(left: 16, right: 16),
          ),
        ],
      ),
    );
  }

  Widget typeWidget() {
    return Container(
      width: 100,
      color: BaseColor.loadBg,
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return typeItemWidget(labels[index], index).onClick(() {
              mCurrentTab = labels[index].id;
              controller.callRefresh();
              setState(() {});
            });
          },
          itemCount: labels.length,
        ),
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
          )
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
          ).marginOn(bottom: 16).onClick(() {
            Get.to(() => BossHomePage(), arguments: operationEntity.entity);
          });
        },
        childCount: 1,
      ),
    );
  }

  Widget bossWidget() {
    return mData.isNullOrEmpty()
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
                return bossItemWidget(mData[index], index);
              },
              childCount: mData.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 4 / 7),
          );
  }

  Widget bossItemWidget(BossInfoEntity entity, int index) {
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
          Text(
            entity.role,
            style: TextStyle(fontSize: 10, color: BaseColor.textGray),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
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
      Get.to(() => BossHomePage(), arguments: entity);
    });
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

  ///widgetStatus=1
  Widget searchWidget() {
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
          Text(
            entity.role,
            style: TextStyle(fontSize: 10, color: BaseColor.textGray),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
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
      Get.to(() => BossHomePage(), arguments: entity);
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