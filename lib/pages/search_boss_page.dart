import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
import 'package:flutter_boss_says/pages/boss_home_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SearchBossPage extends StatefulWidget {
  SearchBossPage({Key key}) : super(key: key);

  @override
  _SearchBossPageState createState() => _SearchBossPageState();
}

class _SearchBossPageState extends State<SearchBossPage>
    with BasePageController<BossInfoEntity> {
  String searchText;

  var builderFuture;

  TextEditingController editingController;
  ScrollController scrollController;
  EasyRefreshController controller;
  FocusNode focusNode;

  bool hasData = false;

  @override
  void dispose() {
    super.dispose();
    editingController?.dispose();
    controller?.dispose();
    scrollController?.dispose();
    focusNode?.dispose();

    TalkingApi.ins().obtainPageEnd(TalkingApi.SearchBoss);
  }

  @override
  void initState() {
    super.initState();
    searchText = "";

    editingController = TextEditingController();

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
    focusNode = FocusNode();

    TalkingApi.ins().obtainPageStart(TalkingApi.SearchBoss);
  }

  ///初始化数据
  Future<bool> loadInitData() {
    if (searchText == "") {
      return Observable.just(true).last;
    } else {
      return BossApi.ins()
          .obtainSearchBossList(pageParam, searchText)
          .flatMap((value) {
        pageParam?.reset();
        hasData = value.hasData;
        concat(value.records, false);
        return Observable.just(false);
      }).last;
    }
  }

  ///刷新数据/加载更多
  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainSearchBossList(pageParam, searchText).listen((event) {
      hasData = event.hasData;
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

  ///清除搜索框
  void onEditCleared() {
    if (!editingController.text.isNullOrEmpty()) {
      editingController.clear();
      searchText = "";
      builderFuture = loadInitData();
      setState(() {});
    }
  }

  ///搜索框：提交
  void onEditSubmitted(String text) {
    if (!text.isNullOrEmpty()) {
      focusNode.unfocus();
      searchText = text;
      builderFuture = loadInitData();
      setState(() {});
    }
  }

  void onEditChanged(text) {
    print('onEditChanged');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseColor.pageBg,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            topWidget(),
            Expanded(
              child: FutureBuilder<bool>(
                builder: builderWidget,
                future: builderFuture,
              ),
            ),
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
            child: Obx(
              () => TextField(
                focusNode: focusNode,
                controller: editingController,
                cursorColor: BaseColor.accent,
                maxLines: 1,
                textAlign: TextAlign.start,
                autofocus: false,
                style: TextStyle(fontSize: 16, color: BaseColor.textDark),
                decoration: InputDecoration(
                  hintText: Global.hint.hint.value == "-1"
                      ? "查找追踪过的老板"
                      : Global.hint.hint.value,
                  hintStyle: TextStyle(fontSize: 16, color: BaseColor.textGray),
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
              ),
            ).marginOn(left: 20),
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

  Widget builderWidget(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return contentWidget(snapshot.data);
      } else
        return BaseWidget.errorWidget(() {
          builderFuture = loadInitData();
          setState(() {});
        });
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget(bool isSearchEmpty) {
    return isSearchEmpty
        ? initBodyWidget()
        : Container(
            color: BaseColor.pageBg,
            child: BaseWidget.refreshWidgetPage(
              slivers: [bodyWidget()],
              controller: controller,
              scrollController: scrollController,
              hasData: hasData,
              loadData: loadData,
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
                return bodyItemWidget(mData[index], index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget bodyItemWidget(BossInfoEntity entity, int index) {
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      height: 80,
      color: BaseColor.pageBg,
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              entity.head,
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
                            Flexible(
                              child: Text(
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
                            ),
                            Image.asset(
                              R.assetsImgBossLabel,
                              width: 56,
                              height: 16,
                            ).marginOn(left: 8),
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
      Get.to(() => BossHomePage(), arguments: entity);
    });
  }

  Widget emptyBodyWidget() {
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        56;
    return Container(
      height: height,
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
            "暂无搜索结果",
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

  Widget initBodyWidget() {
    return Container(
      color: BaseColor.loadBg,
      child: Column(
        children: [
          Container(
            height: 48,
            color: BaseColor.pageBg,
          ),
          Container(
            height: 4,
            color: BaseColor.loadBg,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 184,
            color: BaseColor.pageBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  R.assetsImgEmptyBoss,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                Obx(
                  () => Text(
                    "从追踪的${Global.user.user.value.traceNum ?? 0}位boss中查找",
                    style: TextStyle(color: BaseColor.textGray, fontSize: 16),
                    textAlign: TextAlign.center,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(top: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
