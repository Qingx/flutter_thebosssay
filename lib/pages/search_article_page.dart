import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_global.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/config/page_data.dart' as WlPage;
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/server/app_api.dart';
import 'package:flutter_boss_says/data/server/talking_api.dart';
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

    TalkingApi.ins().obtainPageEnd(TalkingApi.SearchArticle);
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

    TalkingApi.ins().obtainPageStart(TalkingApi.SearchArticle);
  }

  ///初始化数据
  Future<WlPage.Page<ArticleEntity>> loadInitData() {
    return AppApi.ins()
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

    AppApi.ins().obtainSearchArticleList(pageParam, searchText).listen((event) {
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
      controller.callRefresh();
    }
  }

  ///搜索框：提交
  void onEditSubmitted(String text) {
    if (!text.isNullOrEmpty()) {
      focusNode.unfocus();
      searchText = text;
      controller.callRefresh();
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
                      ? "请输入内容"
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
          }),
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

                return entity.files.isNullOrEmpty()
                    ? ArticleWidget.onlyTextWithContent(entity, context)
                    : ArticleWidget.singleImgWithContent(entity, context);
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
