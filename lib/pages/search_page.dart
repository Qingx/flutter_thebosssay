import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/dialog/follow_success_dialog.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with BasePageController {
  String hintText = "大家都在搜莉莉娅";
  TextEditingController editingController;

  var builderFuture;
  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = false;

  List<int> typeList = [0, 1, 2, 3, 4, 5, 6, 7];
  int mCurrentType = 0;

  //0:首页界面 1:搜索结果页面 2:搜索结果空界面
  int widgetStatus = 0;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

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

    editingController = TextEditingController();

    // concat([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], false);
    builderFuture = getData();

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    List<int> testData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    Observable.just(testData).delay(Duration(seconds: 2)).listen((event) {
      hasData = true;
      concat(event, loadMore);
      setState(() {});
    }, onDone: () {
      if (loadMore) {
        controller.finishLoad();
      } else {
        controller.resetLoadState();
        controller.finishRefresh();
      }
    });
  }

  void onEditCleared() {
    if (!editingController.text.isNullOrEmpty()) {
      editingController.clear();
      widgetStatus = 0;
      builderFuture = getData();
      setState(() {});
    }
  }

  void onEditSubmitted(text) {
    widgetStatus = 1;
    builderFuture = getData();
    Fluttertoast.showToast(msg: text);
    setState(() {});
  }

  void onEditChanged(text) {
    print('onEditChanged');
  }

  void onFollowChanged(bool isChanged) {
    showFollowSuccessDialog(context, onConfirm: () {
      BaseTool.toast(msg: "onConfirm");
    }, onDismiss: () {
      BaseTool.toast(msg: "onDismiss");
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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

  Widget bodyWidget() {
    return FutureBuilder<bool>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      print('data:${snapshot.data}');
      if (snapshot.hasData) {
        if (widgetStatus == 0) {
          return contentWidget();
        } else if (widgetStatus == 1) {
          return searchWidget();
        } else {
          return searchEmptyWidget();
        }
      } else
        return Container(color: Colors.red);
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
                    slivers: [adWidget(), bossWidget()],
                    controller: controller,
                    scrollController: scrollController,
                    hasData: hasData,
                    loadData: loadData)
                .paddingOnly(left: 16, right: 16),
          ),
        ],
      ),
    );
  }

  Widget typeWidget() {
    return Container(
      width: 96,
      color: BaseColor.loadBg,
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return typeItemWidget(index).onClick(() {
              mCurrentType = index;
              controller.callRefresh();
              setState(() {});
            });
          },
          itemCount: typeList.length,
        ),
      ),
    );
  }

  Widget typeItemWidget(int index) {
    Color color = index == mCurrentType ? BaseColor.pageBg : BaseColor.loadBg;
    String text = index == 0
        ? "为你推荐"
        : index % 2 == 0
            ? "混子上单"
            : "草食打野";
    return index == mCurrentType
        ? Container(
            width: 96,
            height: 64,
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
                text,
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
              text,
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

  Widget adWidget() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Image.asset(
            R.assetsImgTestPhoto,
            height: 100,
            fit: BoxFit.cover,
          ).marginOn(bottom: 16);
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
                return bossItemWidget(index);
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

  Widget bossItemWidget(int index) {
    String head = index % 2 == 0 ? R.assetsImgTestPhoto : R.assetsImgTestHead;
    String name = index % 2 == 0 ? "莉莉娅" : "神里凌华";
    String content = index % 2 == 0 ? "灵魂莲华" : "精神信仰";
    Color labelColor = index % 2 == 0 ? BaseColor.accent : BaseColor.loadBg;
    String label = index % 2 == 0
        ? R.assetsImgBossOrderNormal
        : R.assetsImgBossOrderSelect;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              head,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            name,
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
            content,
            style: TextStyle(fontSize: 12, color: BaseColor.textGray),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            width: 40,
            height: 18,
            margin: EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            child: Image.asset(
              label,
              width: 14,
              height: 14,
            ),
          ),
        ],
      ),
    ).onClick(() {
      onFollowChanged(true);
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
    return Container(
      child: Column(
        children: [
          searchTitleWidget(),
          Expanded(child: searchResultWidget()),
        ],
      ),
    );
  }

  Widget searchTitleWidget() {
    int number = 4;
    return Container(
      alignment: Alignment.centerLeft,
      height: 40,
      child: RichText(
        text: new TextSpan(
          text: "共找到",
          style: TextStyle(
              color: BaseColor.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: " $number ",
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
            return searchItemWidget(index);
          },
          itemCount: 8,
        ),
      ),
    );
  }

  Widget searchItemWidget(int index) {
    String head = index % 2 == 0 ? R.assetsImgTestPhoto : R.assetsImgTestHead;
    String name = index % 2 == 0 ? "莉莉娅" : "神里凌华";
    String content = index % 2 == 0 ? "灵魂莲华" : "精神信仰";
    Color labelColor = index % 2 == 0 ? BaseColor.accent : BaseColor.loadBg;
    String label = index % 2 == 0
        ? R.assetsImgBossOrderNormal
        : R.assetsImgBossOrderSelect;

    return Container(
      color: BaseColor.pageBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              head,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            name,
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
            content,
            style: TextStyle(fontSize: 12, color: BaseColor.textGray),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            width: 40,
            height: 18,
            margin: EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            child: Image.asset(
              label,
              width: 14,
              height: 14,
            ),
          ).onClick(() {
            onFollowChanged(true);
          }),
        ],
      ),
    );
  }

  ///widgetStatus=2
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
