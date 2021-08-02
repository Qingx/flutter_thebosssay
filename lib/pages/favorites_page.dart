import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/favorite_entity.dart';
import 'package:flutter_boss_says/data/server/user_api.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/event/refresh_user_event.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_event.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'article_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  List<FavoriteEntity> mData = [];
  List<String> mSelectId = [];

  StreamSubscription<BaseEvent> eventDispose;

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

    eventBus();
  }

  void eventBus() {
    eventDispose = Global.eventBus.on<BaseEvent>().listen((event) {
      if (event.obj == RefreshCollectEvent) {
        controller?.callRefresh();
      }
    });
  }

  ///初始化数据
  Future<List<FavoriteEntity>> loadInitData() {
    return UserApi.ins().obtainFavoriteList().doOnData((event) {
      mData = event;
    }).last;
  }

  ///刷新数据
  void loadData() {
    UserApi.ins().obtainFavoriteList().listen((event) {
      mData = event;
      mSelectId.clear();
      setState(() {});

      controller.finishRefresh(success: true);
    }, onError: (res) {
      controller.finishRefresh(success: false);
    });
  }

  ///删除收藏夹
  void onRemoveFavorite(FavoriteEntity entity) {
    BaseWidget.showLoadingAlert("尝试删除...", context);
    UserApi.ins().obtainRemoveFavorite(entity.id).listen((event) {
      mData.remove(entity);

      var user = Global.user.user.value;
      user.collectNum = user.collectNum - entity.list.length ?? 0;
      Global.user.setUser(user);

      Global.eventBus.fire(BaseEvent(RefreshUserEvent));

      BaseTool.toast(msg: "删除成功");
      Get.back();
      setState(() {});
    }, onError: (res) {
      Get.back();
      print(res.msg);
      BaseTool.toast(msg: "删除失败，${res.msg}");
    });
  }

  ///取消收藏文章
  void onRemoveArticle(String favoriteId, ArticleEntity entity) {
    BaseWidget.showLoadingAlert("尝试取消收藏", context);

    UserApi.ins().obtainCancelFavoriteArticle(entity.id).listen((event) {
      Get.back();

      FavoriteEntity favoriteEntity =
          mData.firstWhere((element) => element.id == favoriteId);
      favoriteEntity.list.remove(entity);

      var user = Global.user.user.value;
      user.collectNum--;
      Global.user.setUser(user);

      Global.eventBus.fire(BaseEvent(RefreshUserEvent));
      setState(() {});
    }, onError: (res) {
      Get.back();
      print('${res.msg}');
      BaseTool.toast(msg: "取消失败，${res.msg}");
    });
  }

  ///展开/收起
  void onTitleClick(FavoriteEntity entity) {
    if (!entity.list.isNullOrEmpty()) {
      if (mSelectId.contains(entity.id)) {
        mSelectId.remove(entity.id);
      } else {
        mSelectId.add(entity.id);
      }
      setState(() {});
    }
  }

  ///点击文章
  void onArticleClick(ArticleEntity entity) {
    BaseTool.toast(msg: entity.title);
  }

  ///添加收藏夹
  void showAddFolder() {
    showNewFolderDialog(context, onDismiss: () {
      Get.back();
    }, onConfirm: onAddFolder);
  }

  ///添加收藏夹
  void onAddFolder(name) {
    BaseWidget.showLoadingAlert("尝试新建...", context);
    UserApi.ins().obtainCreateFavorite(name).listen((event) {
      mData.add(event);

      Get.back();
      Get.back();
      BaseTool.toast(msg: "新建成功");
      setState(() {});
    }, onError: (res) {
      Get.back();
      print(res.msg);
      BaseTool.toast(msg: "新建失败，${res.msg}");
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
                      child: Obx(
                        () => Text(
                          "我的收藏（${Global.user.user.value.collectNum ?? 0}）",
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
                  ),
                ],
              ),
            ),
            Expanded(child: bodyWidget()),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget() {
    return FutureBuilder<List<FavoriteEntity>>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(
      BuildContext context, AsyncSnapshot<List<FavoriteEntity>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return Stack(
          children: [
            contentWidget().positionOn(top: 0, bottom: 0, left: 0, right: 0),
            floatWidget().positionOn(
                bottom: MediaQuery.of(context).padding.bottom + 64, right: 16),
          ],
        );
      } else
        return BaseWidget.errorWidget(() {
          loadData();
        });
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidget(
          slivers: [
            listWidget(),
          ],
          controller: controller,
          scrollController: scrollController,
          loadData: loadData),
    );
  }

  Widget listWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return listItemWidget(mData[index], index);
        },
        childCount: mData.length,
      ),
    );
  }

  Widget listItemWidget(FavoriteEntity entity, index) {
    bool hasSelect = mSelectId.contains(mData[index].id);

    return Container(
      child: Column(
        children: [
          Slidable(
            child: Container(
              height: 56,
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      entity.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: BaseColor.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: false,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${entity.list?.length ?? 0}篇言论",
                    style: TextStyle(color: BaseColor.accent, fontSize: 14),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).onClick(() {
              onTitleClick(entity);
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  onRemoveFavorite(entity);
                },
              ),
            ],
          ),
          Visibility(
            visible: hasSelect,
            child: Container(
              child: articleWidget(entity),
            ),
          ),
          Container(
            height: 1,
            color: BaseColor.line,
          ),
        ],
      ),
    );
  }

  Widget articleWidget(FavoriteEntity entity) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeTop: true,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return articleItemWidget(entity.id, entity.list[index], index);
        },
        itemCount: entity.list?.length ?? 0,
      ),
    );
  }

  Widget articleItemWidget(String favoriteId, ArticleEntity entity, int index) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 1,
            color: BaseColor.line,
            margin: EdgeInsets.only(left: 16, right: 16),
          ),
          Slidable(
            child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.title,
                      style: TextStyle(fontSize: 14, color: BaseColor.textDark),
                      softWrap: true,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipOval(
                          child: Image.network(
                            HttpConfig.fullUrl(entity.bossVO.head),
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                R.assetsImgDefaultHead,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Text(
                          entity.bossVO.name,
                          style: TextStyle(
                              fontSize: 14, color: BaseColor.textGray),
                          softWrap: false,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).marginOn(left: 8),
                        Expanded(child: SizedBox()),
                        Text(
                          BaseTool.getArticleItemTime(entity.releaseTime),
                          style: TextStyle(
                            fontSize: 13,
                            color: BaseColor.textGray,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ).marginOn(top: 8),
                  ],
                )),
            actionPane: SlidableScrollActionPane(),
            actionExtentRatio: 0.25,
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '取消收藏',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: false,
                onTap: () {
                  onRemoveArticle(favoriteId, entity);
                },
              ),
            ],
          ),
        ],
      ),
    ).onClick(() {
      Get.to(() => ArticlePage(), arguments: entity.id);
    });
  }

  Widget floatWidget() {
    return Container(
      alignment: Alignment.center,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: BaseColor.loadBg,
              offset: Offset(0.0, 4.0), //阴影x,y轴偏移量
              blurRadius: 4, //阴影模糊程度
              spreadRadius: 0 //阴影扩散程度
              )
        ],
      ),
      child: Icon(
        Icons.add,
        color: BaseColor.textDark,
        size: 24,
      ),
    ).onClick(showAddFolder);
  }
}
