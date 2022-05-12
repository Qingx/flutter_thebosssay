import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/config/user_config.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/data/entity/his_fav_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/dialog/daily_dialog.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/refresh_point_event.dart';
import 'package:flutter_boss_says/pages/daily_poster_page.dart';
import 'package:flutter_boss_says/pages/login_phone_wechat.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:flutter_boss_says/util/tab_size_indicator.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../r.dart';

class MinePointPage extends StatefulWidget {
  const MinePointPage({Key key}) : super(key: key);

  @override
  _MinePointPageState createState() => _MinePointPageState();
}

class _MinePointPageState extends State<MinePointPage>
    with SingleTickerProviderStateMixin {
  List<String> typeList;
  List<Widget> pages;
  TabController tabController;

  @override
  void dispose() {
    super.dispose();

    tabController?.dispose();
  }

  @override
  void initState() {
    super.initState();

    typeList = ["文章", "Boss语录"];
    pages = [PointWidget("1"), PointWidget("2")];
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            Container(
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
                      height: 32,
                      margin: EdgeInsets.only(right: 68, left: 40),
                      alignment: Alignment.center,
                      child: TabBar(
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        indicator: TabSizeIndicator(
                          borderSide:
                              BorderSide(width: 2, color: BaseColor.accent),
                          wantWidth: 16,
                        ),
                        labelColor: BaseColor.accent,
                        unselectedLabelColor: Color(0xff979797),
                        indicatorColor: BaseColor.accent,
                        controller: tabController,
                        tabs: [
                          Tab(
                            text: typeList[0],
                          ),
                          Tab(
                            text: typeList[1],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: BaseColor.lineNew,
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  pages[0],
                  pages[1],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PointWidget extends StatefulWidget {
  String code;

  PointWidget(this.code, {Key key}) : super(key: key);

  @override
  _PointWidgetState createState() => _PointWidgetState();
}

class _PointWidgetState extends State<PointWidget>
    with BasePageController<HisFavEntity>, AutomaticKeepAliveClientMixin {
  var builderFuture;
  bool hasData;

  ScrollController scrollController;
  EasyRefreshController controller;

  var pointDis;

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();

    pointDis?.cancel();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    builderFuture = loadInitData();

    eventBus();
  }

  Future<dynamic> loadInitData() {
    return AppApi.ins()
        .obtainPointList(pageParam, widget.code)
        .doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).last;
  }

  void eventBus() {
    pointDis = Global.eventBus.on<RefreshPointEvent>().listen((event) {
      if (event.doPoint) {
        controller.callRefresh();
      } else {
        int index =
            mData.indexWhere((element) => element.articleId == event.id);
        if (index != -1) {
          mData.removeAt(index);

          setState(() {});
        }
      }
    });
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam?.reset();
    }

    AppApi.ins().obtainPointList(pageParam, widget.code).listen((event) {
      hasData = event.hasData;
      concat(event.records, loadMore);
      setState(() {});

      if (loadMore) {
        controller.finishLoad(success: true);
      } else {
        controller.finishRefresh(success: true);
      }
    }).onError((res) {
      if (loadMore) {
        controller.finishLoad(success: false);
      } else {
        controller.finishRefresh(success: false);
      }
    });
  }

  ///取消文章点赞
  void removeArticle(HisFavEntity entity, int index) {
    BaseWidget.showLoadingAlert("尝试取消...", context);

    AppApi.ins().obtainCancelPoint(entity.articleId).listen((event) {
      Get.back();

      mData.removeAt(index);

      UserEntity entity = UserConfig.getIns().user;
      entity.pointNum--;
      Global.user.setUser(entity);

      setState(() {});
    }, onError: (res) {
      Get.back();
      print(res.msg);
      BaseTool.toast(msg: "取消失败，${res.msg}");
    });
  }

  ///取消每日一言点赞
  void removeDaily(HisFavEntity entity, int index) {
    BaseWidget.showLoadingAlert("尝试取消...", context);

    AppApi.ins().obtainPointDaily(entity.articleId, false).listen((event) {
      Get.back();

      mData.removeAt(index);

      UserEntity entity = UserConfig.getIns().user;
      entity.pointNum--;
      Global.user.setUser(entity);

      setState(() {});
    }, onError: (res) {
      Get.back();
      print(res.msg);
      BaseTool.toast(msg: "取消失败，${res.msg}");
    });
  }

  ///点击文章
  void clickArticle(String id) {
    Get.to(() => WebArticlePage(fromBoss: false), arguments: id);
  }

  ///点击每日一言
  void clickDaily(DailyEntity entity) {
    showDailyDialog(
      context,
      entity,
      doPoint: (state) {
        doPointDaily(entity, state);
      },
      doFavorite: (state) {
        doFavoriteDaily(entity, state);
      },
      doShare: () {
        showShareDialog(context, true, onDismiss: () {
          Get.back();
        }, doClick: (index) {
          switch (index) {
            case 0:
              BaseTool.shareToSession(
                mDes: entity.content,
                mTitle: "分享一段${entity.bossName}的语录，深有感触",
                thumbnail: HttpConfig.fullUrl(entity.bossHead),
              );
              break;
            case 1:
              BaseTool.shareToTimeline(
                mDes: entity.content,
                mTitle: "分享一段${entity.bossName}的语录，深有感触",
                thumbnail: HttpConfig.fullUrl(entity.bossHead),
              );
              break;
            case 2:
              BaseTool.shareCopyLink();
              break;
            default:
              Get.to(() => DailyPosterPage(entity), preventDuplicates: false);
              break;
          }
        });
      },
    );
  }

  ///每日一言点赞
  void doPointDaily(DailyEntity entity, Function state) {
    var status = !entity.isPoint;
    AppApi.ins().obtainPointDaily(entity.id, status).listen((event) {
      entity.isPoint = status;
      state();

      var user = Global.user.user.value;
      if (status) {
        user.pointNum++;
        controller.callRefresh();
      } else {
        user.pointNum--;

        var index =
            mData.indexWhere((element) => element.articleId == entity.id);
        mData.removeAt(index);
      }
      Global.user.setUser(user);

      setState(() {});
    }, onError: (res) {
      print(res.msg);
      BaseTool.toast(msg: "${status ? "点赞失败" : "取消失败"}，${res.msg}");
    });
  }

  ///每日一言收藏
  void doFavoriteDaily(DailyEntity entity, Function state) {
    if (UserConfig.getIns().loginStatus) {
      if (entity.isCollect) {
        doNoFavorite(entity, state);
      } else {
        showFavoriteFolder(entity, state);
      }
    } else {
      BaseTool.toast(msg: "请先登录！");
      BaseTool.jumpLogin(context);
    }
  }

  ///每日一言取消收藏
  void doNoFavorite(DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试取消收藏...", context);
    AppApi.ins().obtainCancelCollectDaily(entity.id).listen((event) {
      Get.back();

      var user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      entity.isCollect = false;

      int index = mData.indexWhere((element) => element.articleId == entity.id);
      if (index != -1) {
        mData[index].isCollect = false;
      }
      state();

      BaseTool.toast(msg: "取消成功");
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "取消失败");
    });
  }

  ///展示收藏夹
  void showFavoriteFolder(DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("获取收藏夹...", context);
    AppApi.ins().obtainCollectFolder().listen(
      (event) {
        Get.back();

        showSelectFolderDialog(context, event, onDismiss: () {
          Get.back();
        }, onConfirm: (folderId) {
          doAddFavorite(folderId, entity, state);
        }, onCreate: () {
          showAddFolder(entity, state);
        });
      },
      onError: (res) {
        Get.back();
        BaseTool.toast(msg: "获取失败，${res.msg}");
      },
    );
  }

  ///展示创建收藏夹
  void showAddFolder(DailyEntity entity, Function state) {
    showNewFolderDialog(
      context,
      onDismiss: () {
        Get.back();
      },
      onConfirm: (name) {
        doAddFolder(name, entity, state);
      },
    );
  }

  ///添加到新建收藏夹
  void doAddFolder(String name, DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);
    AppApi.ins().obtainCreateFavorite(name).flatMap((value) {
      return AppApi.ins().obtainCollectDaily(entity.id, value.id);
    }).listen((event) {
      Get.back();
      Get.back();
      Get.back();

      entity.isCollect = true;
      int index = mData.indexWhere((element) => element.articleId == entity.id);
      if (index != -1) {
        mData[index].isCollect = true;
      }
      state();

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败，${res.msg}");
    });
  }

  ///每日一言收藏
  void doAddFavorite(String folderId, DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);

    AppApi.ins().obtainCollectDaily(entity.id, folderId).listen((event) {
      Get.back();
      Get.back();

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      entity.isCollect = true;
      int index = mData.indexWhere((element) => element.articleId == entity.id);
      if (index != -1) {
        mData[index].isCollect = true;
      }

      state();

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败，${res.msg}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
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
    return Container(
      child: BaseWidget.refreshWidgetPage(
        slivers: [
          listWidget(),
        ],
        controller: controller,
        scrollController: scrollController,
        hasData: hasData,
        loadData: loadData,
      ),
    );
  }

  Widget listWidget() {
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
                var entity = mData[index];
                return entity.hidden
                    ? articleHiddenItem(entity, index)
                    : widget.code == "1"
                        ? articleItemWidget(entity, index)
                        : dailyItemWidget(entity, index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget articleItemWidget(HisFavEntity entity, index) {
    String labelIcon =
        entity.articleType == "1" ? R.assetsImgTypeTalk : R.assetsImgTypeMsg;
    String labelName = entity.articleType == "1" ? "言论" : "资讯";
    Color labelColor =
        entity.articleType == "1" ? Color(0x1fe02020) : Color(0x1f2343c2);
    Color textColor =
        entity.articleType == "1" ? Color(0xffE02020) : Color(0xff2847C3);

    return Container(
      child: Column(
        children: [
          Slidable(
            child: Container(
              height: 112,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.network(
                      HttpConfig.fullUrl(entity.cover),
                      width: 112,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          R.assetsImgDefaultArticleCover,
                          width: 112,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ).marginOn(right: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entity.content,
                          style: TextStyle(
                              color: BaseColor.textDark, fontSize: 14),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        Expanded(child: SizedBox()),
                        Container(
                          height: 20,
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              color: labelColor,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  labelIcon,
                                  width: 10,
                                  height: 10,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  labelName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  HttpConfig.fullUrl(entity.bossHead),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      R.assetsImgDefaultHead,
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entity.bossName,
                                  style: TextStyle(
                                    color: Color(0xff7c7c7c),
                                    fontSize: 10,
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ).marginOn(left: 8, right: 8),
                              ),
                              Text(
                                DateFormat.getYYMMDD(entity.createTime),
                                style: TextStyle(
                                  color: Color(0xff7c7c7c),
                                  fontSize: 10,
                                ),
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).onClick(() {
              clickArticle(entity.articleId);
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  removeArticle(entity, index);
                },
              ),
            ],
          ),
          Container(
            height: 1,
            color: BaseColor.lineNew,
          ),
        ],
      ),
    );
  }

  Widget dailyItemWidget(HisFavEntity entity, index) {
    return Container(
      child: Column(
        children: [
          Slidable(
            child: Container(
              height: 112,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      R.assetsImgDefaultArticleCover,
                      width: 112,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ).marginOn(right: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entity.content,
                          style: TextStyle(
                              color: BaseColor.textDark, fontSize: 12),
                          maxLines: 3,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        Container(
                          height: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  HttpConfig.fullUrl(entity.bossHead),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      R.assetsImgDefaultHead,
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entity.bossName,
                                  style: TextStyle(
                                    color: Color(0xff7c7c7c),
                                    fontSize: 10,
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ).marginOn(left: 8, right: 8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).onClick(() {
              clickDaily(entity.toDaily());
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  removeDaily(entity, index);
                },
              ),
            ],
          ),
          Container(
            height: 1,
            color: BaseColor.lineNew,
          ),
        ],
      ),
    );
  }

  Widget articleHiddenItem(HisFavEntity entity, index) {
    return Container(
      child: Column(
        children: [
          Slidable(
            child: Container(
              color: BaseColor.pageBg,
              height: 112,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.asset(
                      R.assetsImgDefaultArticleCover,
                      height: 80,
                      width: 112,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ).marginOn(right: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Boss已下架，内容不予显示",
                          style: TextStyle(
                              color: BaseColor.textDark, fontSize: 14),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        Expanded(child: SizedBox()),
                        Container(
                          height: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  HttpConfig.fullUrl(entity.bossHead),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      R.assetsImgDefaultHead,
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Text(
                                entity.bossName,
                                style: TextStyle(
                                  color: Color(0xff7c7c7c),
                                  fontSize: 10,
                                ),
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ).marginOn(left: 8, right: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).onClick(() {
              BaseTool.toast(msg: "Boss已下架，内容不予显示");
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  removeArticle(entity, index);
                },
              ),
            ],
          ),
          Container(
            height: 1,
            color: BaseColor.lineNew,
          ),
        ],
      ),
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "还没有点赞记录哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        44;
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 160, height: 160),
            Flexible(
                child: Text(content,
                        style:
                            TextStyle(fontSize: 18, color: BaseColor.textGray),
                        textAlign: TextAlign.center)
                    .marginOn(top: 16))
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
    });
  }
}
