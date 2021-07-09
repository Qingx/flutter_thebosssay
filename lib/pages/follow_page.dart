import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/data_config.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/event/refresh_follow_event.dart';
import 'package:flutter_boss_says/event/refresh_user_event.dart';
import 'package:flutter_boss_says/pages/all_boss_page.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_empty.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({Key key}) : super(key: key);

  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage>
    with AutomaticKeepAliveClientMixin, BasePageController<ArticleEntity> {
  ScrollController scrollController;
  EasyRefreshController controller;

  var builderFuture;

  bool hasData = false;
  int totalArticleNumber;
  String mCurrentTab;

  List<BossInfoEntity> bossList = []; //boss card列表数据

  StreamSubscription<BaseEvent> eventDispose;

  @override
  bool get wantKeepAlive => true;

  @override
  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    scrollController?.dispose();

    eventDispose?.cancel();
  }

  @override
  void initState() {
    super.initState();
    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    tempSign();

    eventBus();
  }

  ///eventBus
  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      ///添加追踪boss后刷新
      if (event.obj == RefreshFollowEvent) {
        controller.callRefresh();
      }

      ///刷新userInfo
      if (event.obj == RefreshUserEvent) {
        UserApi.ins().obtainRefreshUser().listen((event) {
          UserConfig.getIns().token = event.token;
          UserConfig.getIns().user = event.userInfo;
          Global.user.setUser(event.userInfo);
        });
      }
    });
  }

  ///退出登录 重新使用设备id注册
  void tempSign() {
    if (UserConfig.getIns().token == "empty_token") {
      UserApi.ins().obtainTempLogin(DataConfig.getIns().tempId).listen((event) {
        UserConfig.getIns().token = event.token;
        UserConfig.getIns().user = event.userInfo;
        Global.user.setUser(event.userInfo);
      });
    }
  }

  ///初始化获取数据
  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    if (Global.labelList.isNullOrEmpty()) {
      return BossApi.ins().obtainBossLabels().flatMap((value) {
        Global.labelList = [BaseEmpty.emptyLabel, ...value];
        mCurrentTab = Global.labelList[0].id;

        return BossApi.ins().obtainFollowBossList(mCurrentTab, true);
      }).flatMap((value) {
        bossList = value;

        return BossApi.ins().obtainFollowArticle(pageParam);
      }).doOnData((event) {
        totalArticleNumber = event.total;
        hasData = event.hasData;
        concat(event.records, false);
      }).doOnError((e) {
        print(e);
      }).last;
    } else {
      mCurrentTab = Global.labelList[0].id;
      return BossApi.ins()
          .obtainFollowBossList(mCurrentTab, true)
          .flatMap((value) {
        bossList = value;

        return BossApi.ins().obtainFollowArticle(pageParam);
      }).doOnData((event) {
        totalArticleNumber = event.total;
        hasData = event.hasData;
        concat(event.records, false);
      }).doOnError((e) {
        print(e);
      }).last;
    }
  }

  ///刷新boss列表 获取文章数据(分页)
  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();

      BossApi.ins().obtainFollowBossList(mCurrentTab, true).flatMap((value) {
        bossList = value;

        return BossApi.ins().obtainFollowArticle(pageParam);
      }).listen((event) {
        totalArticleNumber = event.total;
        hasData = event.hasData;
        concat(event.records, loadMore);
        setState(() {});
      }).onDone(() {
        if (loadMore) {
          controller.finishLoad();
        } else {
          controller.resetLoadState();
          controller.finishRefresh();
        }
      });
    } else {
      BossApi.ins().obtainFollowArticle(pageParam).listen((event) {
        hasData = event.hasData;
        concat(event.records, loadMore);
        setState(() {});
      }).onDone(() {
        if (loadMore) {
          controller.finishLoad();
        } else {
          controller.resetLoadState();
          controller.finishRefresh();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WlPage.Page<ArticleEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context,
      AsyncSnapshot<WlPage.Page<ArticleEntity>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
    } else {
      return loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidgetPage(
          slivers: [topWidget(), bodyWidget()],
          controller: controller,
          scrollController: scrollController,
          hasData: hasData,
          loadData: loadData),
    );
  }

  Widget topWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return tabWidget();
          } else if (index == 1) {
            if (bossList.isNullOrEmpty()) {
              return emptyCardWidget();
            } else
              return cardWidget();
          } else {
            return titleWidget();
          }
        },
        childCount: 3,
      ),
    );
  }

  Widget tabWidget() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(Global.labelList[index], index);
          },
          itemCount: Global.labelList.length,
        ),
      ),
    );
  }

  Widget tabItemWidget(BossLabelEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    bool hasSelect = mCurrentTab == entity.id;

    Color bgColor = hasSelect ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = hasSelect ? Colors.white : BaseColor.accent;

    String name = BaseEmpty.emptyLabel == entity ? "全部" : entity.name;
    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          name,
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      if (entity.id != mCurrentTab) {
        mCurrentTab = entity.id;
        controller.callRefresh();
      }
    });
  }

  Widget cardWidget() {
    return Container(
      height: 188,
      padding: EdgeInsets.only(top: 24, bottom: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return cardItemWidget(bossList[index], index);
          },
          itemCount: bossList.length,
        ),
      ),
    );
  }

  Widget emptyCardWidget() {
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: 12),
      height: 188,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            R.assetsImgEmptyBoss,
            width: 100,
            height: 80,
            fit: BoxFit.cover,
          ),
          Text(
            "当前还没有追踪的老板！",
            style: TextStyle(fontSize: 14, color: Color(0x80000000)),
            textAlign: TextAlign.center,
            softWrap: false,
            maxLines: 1,
          ),
          Container(
            height: 28,
            width: 120,
            decoration: BoxDecoration(
                border: Border.all(color: BaseColor.accent, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Center(
              child: Text(
                "立即添加",
                style: TextStyle(fontSize: 16, color: BaseColor.accent),
                textAlign: TextAlign.center,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ).onClick(() {
            Get.to(() => AllBossPage());
          }),
        ],
      ),
    );
  }

  Widget cardItemWidget(BossInfoEntity entity, int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 64,
            height: 64,
            child: Stack(
              children: [
                ClipOval(
                  child: Image.network(
                    HttpConfig.fullUrl(entity.head),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        index % 2 == 0
                            ? R.assetsImgTestPhoto
                            : R.assetsImgTestHead,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Container(
                  height: 14,
                  padding: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      entity.updateCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ).positionOn(top: 0, right: 0),
              ],
            ),
          ),
          Text(
            entity.name,
            style: TextStyle(color: BaseColor.textDark, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            entity.role,
            style: TextStyle(color: BaseColor.textGray, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).onClick(() {
      Get.to(() => BossHomePage(), arguments: entity);
    });
  }

  Widget titleWidget() {
    return Container(
      color: BaseColor.pageBg,
      height: 40,
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "最近更新",
            style: TextStyle(
                color: BaseColor.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ).marginOn(left: 16),
          Text(
            "共${totalArticleNumber ?? 0}篇",
            style: TextStyle(color: BaseColor.textDark, fontSize: 14),
          ).marginOn(left: 16),
        ],
      ),
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
                ArticleEntity entity = mData[index];

                if (entity.files.isNullOrEmpty()) {
                  return ArticleWidget.onlyTextWithContent(
                      entity, index, context);
                } else {
                  return ArticleWidget.singleImgWithContent(
                      entity, index, context);
                }
              },
              childCount: mData.length,
            ),
          );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "最近还没有更新哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        392;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Flexible(
              child: Text(
                content,
                style: TextStyle(fontSize: 18, color: BaseColor.textGray),
                textAlign: TextAlign.center,
              ).marginOn(top: 16),
            ),
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
    });
  }

  Widget loadingWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          loadTabWidget(),
          loadCardWidget(),
          loadingItemWidget(0.7, 24),
          loadingItemWidget(0.3, 8),
          loadingItemWidget(1, 16),
          loadingItemWidget(1, 8),
          loadingItemWidget(1, 8),
          loadingItemWidget(0.4, 8),
          loadingItemWidget(0.6, 8),
          Container(
            margin: EdgeInsets.only(top: 16, left: 16, right: 16),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SpinKitFadingCircle(
                  color: Color(0xff0e1e1e1),
                  size: 48,
                  duration: Duration(milliseconds: 2000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadTabWidget() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return loadTabItemWidget(index);
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Widget loadTabItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;
    return Container(
      width: 80,
      margin: EdgeInsets.only(left: left, right: right),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        color: BaseColor.loadBg,
      ),
    );
  }

  Widget loadCardWidget() {
    return Container(
      height: 188,
      padding: EdgeInsets.only(top: 24, bottom: 24),
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return loadCardItemWidget(index);
          },
          itemCount: 4,
        ),
      ),
    );
  }

  Widget loadCardItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: BaseColor.loadBg,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right),
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
