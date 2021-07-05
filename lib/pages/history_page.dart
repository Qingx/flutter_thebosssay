import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with BasePageController {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;
  bool hasData = false;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

  @override
  void initState() {
    super.initState();

    builderFuture = getData();
    // concat([0, 1, 2, 3, 4], false);

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BaseColor.pageBg,
      resizeToAvoidBottomPadding: false,
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
                      child: Text(
                        "阅读记录",
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
    return FutureBuilder<bool>(
      builder: builderWidget,
      future: builderFuture,
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      print('data:${snapshot.data}');
      if (snapshot.hasData) {
        return contentWidget();
      } else
        return Container(color: Colors.red);
    } else {
      return BaseWidget.loadingWidget();
    }
  }

  Widget contentWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: BaseWidget.refreshWidgetPage(
          slivers: [
            listWidget(),
          ],
          controller: controller,
          scrollController: scrollController,
          hasData: hasData,
          loadData: loadData),
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
                return listItemWidget(index);
              },
              childCount: mData.length,
            ),
          );
  }

  Widget listItemWidget(index) {
    bool hasIndex = index % 2 == 0;
    String title = hasIndex
        ? "搞什么副业可以月入过万搞什么副业可以月入过万"
        : "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业";
    String head = hasIndex ? R.assetsImgTestPhoto : R.assetsImgTestHead;
    String name = hasIndex ? "莉莉娅" : "神里凌华";
    return Slidable(
      child: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                        child: Image.asset(
                          head,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        name,
                        style:
                            TextStyle(fontSize: 14, color: BaseColor.textGray),
                        softWrap: false,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).marginOn(left: 8),
                      Expanded(child: SizedBox()),
                      Text(
                        "2021/07/04",
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
              ),
            ),
            Visibility(
              child: Container(
                height: 1,
                color: BaseColor.line,
              ),
              visible: index != mData.length - 1,
            ),
          ],
        ),
      ).onClick(() {
        BaseTool.toast(msg: name);
      }),
      actionPane: SlidableScrollActionPane(),
      key: Key(mData[index].toString()),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '删除',
          color: Colors.red,
          icon: Icons.delete,
          closeOnTap: false,
          onTap: () {
            mData.removeAt(index);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget emptyBodyWidget() {
    String path = R.assetsImgEmptyBoss;
    String content = "还没有阅读记录哦～";
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
