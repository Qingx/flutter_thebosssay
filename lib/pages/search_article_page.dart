import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/server/boss_api.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/article_widget.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';

class SearchArticlePage extends StatefulWidget {
  SearchArticlePage({Key key}) : super(key: key);

  @override
  _SearchArticlePageState createState() => _SearchArticlePageState();
}

class _SearchArticlePageState extends State<SearchArticlePage>
    with BasePageController<ArticleEntity> {
  String hintText;
  String searchText;

  var builderFuture;

  TextEditingController editingController;
  ScrollController scrollController;
  EasyRefreshController controller;

  bool hasData = false;

  @override
  void dispose() {
    super.dispose();
    editingController?.dispose();
    controller?.dispose();
    scrollController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    hintText = "大家都在搜莉莉娅";
    searchText = "";

    editingController = TextEditingController();

    builderFuture = loadInitData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  ///初始化数据
  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    return BossApi.ins()
        .obtainSearchArticleList(pageParam, searchText)
        .doOnData((event) {
      hasData = event.hasData;
      concat(event.records, false);
    }).doOnError((res) {
      print(res.msg);
    }).last;
  }

  ///刷新数据/加载更多
  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    BossApi.ins().obtainSearchArticleList(pageParam, searchText).listen(
        (event) {
      hasData = event.hasData;
      concat(event.records, loadMore);
      setState(() {});
    }, onError: (res) {
      print(res.msg);
    }, onDone: () {
      if (loadMore) {
        controller.finishLoad();
      } else {
        controller.resetLoadState();
        controller.finishRefresh();
      }
    });
  }

  ///清除搜索框
  void onEditCleared() {
    if (!editingController.text.isNullOrEmpty()) {
      editingController.clear();
      searchText = "";
      controller.callRefresh();
    }
  }

  ///搜索框：提交
  void onEditSubmitted(text) {
    searchText = text;
    controller.callRefresh();
  }

  void onEditChanged(text) {
    print('onEditChanged');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseColor.pageBg,
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
          children: [
            BaseWidget.statusBar(context, true),
            topWidget(),
            Expanded(
              child: FutureBuilder<WlPage.Page<ArticleEntity>>(
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
      padding: EdgeInsets.only(top: 4, bottom: 12, left: 16, right: 16),
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
            child: TextField(
              controller: editingController,
              cursorColor: BaseColor.accent,
              maxLines: 1,
              textAlign: TextAlign.start,
              autofocus: false,
              style: TextStyle(fontSize: 16, color: BaseColor.textDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 16, color: BaseColor.textGray),
                fillColor: BaseColor.loadBg,
                filled: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                suffixIcon: Icon(
                  Icons.clear,
                  size: 24,
                  color: BaseColor.textDark,
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
            ).marginOn(left: 20),
          ),
        ],
      ),
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
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidgetPage(
          slivers: [bodyWidget()],
          controller: controller,
          scrollController: scrollController,
          hasData: hasData,
          loadData: loadData),
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
}