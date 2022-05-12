
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/folder_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/dialog/new_folder_dialog.dart';
import 'package:flutter_boss_says/event/refresh_collect_event.dart';
import 'package:flutter_boss_says/pages/mine_collect_content_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class MineCollectPage extends StatefulWidget {
  const MineCollectPage({Key key}) : super(key: key);

  @override
  _MineCollectPageState createState() => _MineCollectPageState();
}

class _MineCollectPageState extends State<MineCollectPage> {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  List<FolderEntity> mData = [];

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

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();

    eventBus();
  }

  ///初始化数据
  Future<List<FolderEntity>> loadInitData() {
    return AppApi.ins().obtainCollectFolder().doOnData((event) {
      mData = event;
    }).last;
  }

  ///刷新数据
  void loadData() {
    AppApi.ins().obtainCollectFolder().listen((event) {
      mData = event;
      setState(() {});

      controller.finishRefresh(success: true);
    }, onError: (res) {
      controller.finishRefresh(success: false);
    });
  }

  void eventBus() {
    collectDis = Global.eventBus.on<RefreshCollectEvent>().listen((event) {
      loadData();
    });
  }

  ///添加收藏夹
  void showAddFolder() {
    showNewFolderDialog(
      context,
      onDismiss: () {
        Get.back();
      },
      onConfirm: onAddFolder,
    );
  }

  ///添加收藏夹
  void onAddFolder(name) {
    BaseWidget.showLoadingAlert("尝试新建...", context);
    AppApi.ins().obtainCreateFavorite(name).listen((event) {
      var entity = FolderEntity()
        ..id = event.id
        ..name = name
        ..cover = ""
        ..articleCount = 0
        ..bossCount = 0
        ..createTime = event.createTime;
      mData.add(entity);

      Get.back();
      Get.back();
      BaseTool.toast(msg: "新建成功");
      setState(() {});
    }, onError: (res) {
      Get.back();
      print(res.msg);
      BaseTool.toast(msg: "新建失败");
    });
  }

  ///删除收藏夹
  void onRemoveFavorite(FolderEntity entity) {
    if (entity.name != "默认收藏夹") {
      BaseWidget.showLoadingAlert("尝试删除...", context);
      AppApi.ins().obtainRemoveFolder(entity.id).listen((event) {
        mData.remove(entity);

        var user = Global.user.user.value;
        user.collectNum = user.collectNum - entity.articleCount;
        Global.user.setUser(user);

        BaseTool.toast(msg: "删除成功");
        Get.back();
        setState(() {});
      }, onError: (res) {
        Get.back();
        BaseTool.toast(msg: "删除失败");
      });
    } else {
      BaseTool.toast(msg: "暂不支持删除默认收藏夹");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
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
    return FutureBuilder<dynamic>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
      child: BaseWidget.refreshWidget(
        slivers: [
          listWidget(),
        ],
        controller: controller,
        scrollController: scrollController,
        loadData: loadData,
      ),
    );
  }

  Widget listWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return folderItemWidget(mData[index]);
        },
        childCount: mData.length,
      ),
    );
  }

  Widget folderItemWidget(FolderEntity entity) {
    return Container(
      height: 97,
      child: Column(
        children: [
          Slidable(
            child: Container(
              height: 96,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: Image.network(
                      HttpConfig.fullUrl(entity.cover),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          R.assetsImgDefaultArticleCover,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        );
                      },
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
                              color: BaseColor.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${entity.articleCount}个内容· ${entity.bossCount}个Boss",
                          style: TextStyle(
                            color: Color(0xff7c7c7c),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ).marginOn(top: 8),
                      ],
                    ),
                  ),
                  Image.asset(
                    R.assetsImgFolderChange,
                    width: 14,
                    height: 14,
                    fit: BoxFit.cover,
                  ).marginOn(left: 8),
                ],
              ),
            ).onClick(() {
              Get.to(() => MineCollectContentPage(entity));
            }),
            actionPane: SlidableScrollActionPane(),
            key: Key(entity.id),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                closeOnTap: true,
                onTap: () {
                  onRemoveFavorite(entity);
                },
              ),
            ],
          ),
          Container(
            height: 1,
            color: Color(0x1a979797),
            margin: EdgeInsets.only(left: 96),
          ),
        ],
      ),
    );
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
            color: BaseColor.accentLight,
            offset: Offset(0.0, 4.0), //阴影x,y轴偏移量
            blurRadius: 4, //阴影模糊程度
            spreadRadius: 0, //阴影扩散程度
          ),
        ],
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
    ).onClick(showAddFolder);
  }
}
