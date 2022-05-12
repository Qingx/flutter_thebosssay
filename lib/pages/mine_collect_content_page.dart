import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';
import 'package:flutter_boss_says/data/entity/folder_entity.dart';
import 'package:flutter_boss_says/data/entity/his_fav_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/dialog/daily_dialog.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/select_folder_dialog.dart';
import 'package:flutter_boss_says/dialog/share_dialog.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/pages/daily_poster_page.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class MineCollectContentPage extends StatelessWidget {
  FolderEntity entity;

  MineCollectContentPage(this.entity, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top + 152,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(R.assetsImgCollectTopBg),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 16),
                    alignment: Alignment.centerLeft,
                    height: 40,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ).onClick(() {
                      Get.back();
                    }),
                  ),
                  Container(
                    height: 96,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          child: Image.network(
                            HttpConfig.fullUrl(entity.cover),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              return Image.asset(
                                R.assetsImgDefaultArticleCover,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ).marginOn(right: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entity.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              TextWidget(
                                entity.articleCount,
                                entity.bossCount,
                                entity.id,
                              ).marginOn(top: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(child: BodyContent(entity.id))
          ],
        ),
      ),
    );
  }
}

class TextWidget extends StatefulWidget {
  int articleCount;
  int bossCount;
  String id;

  TextWidget(this.articleCount, this.bossCount, this.id, {Key key})
      : super(key: key);

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  var collectDis;

  @override
  void dispose() {
    super.dispose();

    collectDis?.cancel();
  }

  @override
  void initState() {
    super.initState();

    eventBus();
  }

  void eventBus() {
    collectDis = Global.eventBus.on<RefreshCollectEvent>().listen((event) {
      AppApi.ins().obtainGetFolder(widget.id).listen((event) {
        widget.articleCount = event.articleCount;
        widget.bossCount = event.bossCount;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.articleCount}个内容· ${widget.bossCount}个Boss",
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      textAlign: TextAlign.start,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class BodyContent extends StatefulWidget {
  String folderId;

  BodyContent(this.folderId, {Key key}) : super(key: key);

  @override
  _BodyContentState createState() => _BodyContentState();
}

class _BodyContentState extends State<BodyContent>
    with BasePageController<HisFavEntity> {
  var builderFuture;
  bool hasData;

  ScrollController scrollController;
  EasyRefreshController controller;
  var collectDis;

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();
    collectDis?.cancel();
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    builderFuture = loadInitData();

    eventBus();
  }

  void eventBus() {
    collectDis = Global.eventBus.on<RefreshCollectEvent>().listen((event) {
      if (!event.fromFolder) {
        if (event.doCollect) {
          loadData(false);
        } else {
          var index = mData
              .indexWhere((element) => element.articleId == event.articleId);
          if (index != -1) {
            mData.removeAt(index);
          }
          setState(() {});
        }
      }
    });
  }

  Future<dynamic> loadInitData() {
    return AppApi.ins()
        .obtainFolderArticle(pageParam, widget.folderId, "")
        .doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).last;
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam?.reset();
    }

    var lastId = loadMore
        ? mData.isNullOrEmpty()
            ? ""
            : mData[mData.length - 1].articleId
        : "";

    AppApi.ins()
        .obtainFolderArticle(pageParam, widget.folderId, lastId)
        .listen((event) {
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

  ///取消收藏文章
  void doCancelArticle(HisFavEntity entity) {
    BaseWidget.showLoadingAlert("尝试取消收藏", context);

    AppApi.ins().obtainCancelCollectArticle(entity.articleId).listen((event) {
      Get.back();

      var index =
          mData.indexWhere((element) => element.articleId == entity.articleId);
      if (index != -1) {
        mData.removeAt(index);
      }

      var user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      Global.eventBus.fire(RefreshCollectEvent(fromFolder: true));

      BaseTool.toast(msg: "取消成功");
      setState(() {});
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "取消失败");
    });
  }

  ///取消收藏每日一言
  void doCancelDaily(HisFavEntity entity) {
    BaseWidget.showLoadingAlert("尝试取消收藏...", context);
    AppApi.ins().obtainCancelCollectDaily(entity.articleId).listen((event) {
      Get.back();

      int index =
          mData.indexWhere((element) => element.articleId == entity.articleId);
      if (index != -1) {
        mData.removeAt(index);
      }

      var user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      Global.eventBus.fire(RefreshCollectEvent(fromFolder: true));

      BaseTool.toast(msg: "取消成功");
      setState(() {});
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "取消失败");
    });
  }

  void doClickDaily(DailyEntity entity) {
    showDailyDialog(
      context,
      entity,
      doPoint: (state) {
        doPointDaily(entity, state);
      },
      doFavorite: (state) {
        doDailyCollectChanged(entity, state);
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

      var index = mData.indexWhere((element) => element.articleId == entity.id);
      if (index != -1) {
        mData[index].isPoint = status;
      }
      setState(() {});

      var user = Global.user.user.value;
      if (status) {
        user.pointNum++;
      } else {
        user.pointNum--;
      }
      Global.user.setUser(user);

      setState(() {});
    }, onError: (res) {
      print(res.msg);
      BaseTool.toast(msg: "${status ? "点赞失败" : "取消失败"}");
    });
  }

  void doDailyCollectChanged(DailyEntity entity, Function state) {
    if (entity.isCollect) {
      doCancelCollectDaily(entity, state);
    } else {
      showFolder(entity, state);
    }
  }

  void doCancelCollectDaily(DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试取消收藏...", context);
    AppApi.ins().obtainCancelCollectDaily(entity.id).listen((event) {
      Get.back();

      entity.isCollect = false;
      state();

      var user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      Global.eventBus.fire(RefreshCollectEvent(
          fromFolder: false, doCollect: false, articleId: entity.id));
      BaseTool.toast(msg: "取消成功");
    }, onError: (res) {
      Get.back();
      BaseTool.toast(msg: "取消失败");
    });
  }

  ///展示收藏夹
  void showFolder(DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("获取收藏夹...", context);
    AppApi.ins().obtainCollectFolder().listen(
      (event) {
        Get.back();

        showSelectFolderDialog(context, event, onDismiss: () {
          Get.back();
        }, onConfirm: (folderId) {
          doCollectDailyToDefaultFolder(folderId, entity, state);
        }, onCreate: () {
          showAddFolder(entity, state);
        });
      },
      onError: (res) {
        Get.back();
        BaseTool.toast(msg: "获取失败");
      },
    );
  }

  void doCollectDailyToDefaultFolder(
      String folderId, DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);

    AppApi.ins().obtainCollectDaily(entity.id, folderId).listen((event) {
      Get.back();
      Get.back();

      entity.isCollect = true;
      state();

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      Global.eventBus
          .fire(RefreshCollectEvent(fromFolder: false, doCollect: true));

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败");
    });
  }

  ///展示创建收藏夹
  void showAddFolder(DailyEntity entity, Function state) {
    showNewFolderDialog(
      context,
      onDismiss: () {
        Get.back();
      },
      onConfirm: (name) {
        doCollectDailyToNewFolder(name, entity, state);
      },
    );
  }

  ///添加到新建收藏夹
  void doCollectDailyToNewFolder(
      String name, DailyEntity entity, Function state) {
    BaseWidget.showLoadingAlert("尝试收藏...", context);
    AppApi.ins().obtainCreateFavorite(name).flatMap((value) {
      return AppApi.ins().obtainCollectDaily(entity.id, value.id);
    }).listen((event) {
      Get.back();
      Get.back();
      Get.back();

      entity.isCollect = true;
      state();

      var user = Global.user.user.value;
      user.collectNum++;
      Global.user.setUser(user);

      Global.eventBus
          .fire(RefreshCollectEvent(fromFolder: false, doCollect: true));

      BaseTool.toast(msg: "收藏成功");
    }, onError: (res) {
      Get.back();

      print(res.msg);
      BaseTool.toast(msg: "收藏失败");
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
                    : entity.type == "1"
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
                            color: BaseColor.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      R.assetsImgDefaultHead,
                                      width: 18,
                                      height: 18,
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
                                "${DateFormat.getYYMMDD(entity.createTime)}收藏",
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
              Get.to(() => WebArticlePage(fromBoss: false),
                  arguments: entity.articleId);
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.articleId),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: true,
                onTap: () {
                  doCancelArticle(entity);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.content,
                    style: TextStyle(
                      color: BaseColor.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
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
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                R.assetsImgDefaultHead,
                                width: 18,
                                height: 18,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${entity.bossName}·${entity.bossRole}",
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
                          "${DateFormat.getYYMMDD(entity.createTime)}收藏",
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
            ).onClick(() {
              doClickDaily(entity.toDaily());
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.articleId),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: true,
                onTap: () {
                  doCancelDaily(entity);
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
                            color: BaseColor.textDark,
                            fontSize: 14,
                          ),
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
            key: Key(entity.articleId),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: true,
                onTap: () {
                  if (entity.type == "1") {
                    doCancelArticle(entity);
                  } else {
                    doCancelDaily(entity);
                  }
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
    String content = "还没有收藏记录哦～";
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        136;
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
            ).marginOn(top: 16))
          ],
        ),
      ),
    ).onClick(() {
      controller.callRefresh();
    });
  }
}
