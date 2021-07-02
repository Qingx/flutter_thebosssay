import 'package:flutter/material.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  var builderFuture;

  ScrollController scrollController;
  EasyRefreshController controller;

  List<FavoriteModel> mData = [];
  List<int> mSelectId = [];
  int numbers = 0;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

  @override
  void initState() {
    super.initState();

    builderFuture = getData();
    mData = [
      FavoriteModel(0, [0, 1, 2, 3, 4, 5]),
      FavoriteModel(1, [0, 1, 2, 3]),
      FavoriteModel(2, [0, 1]),
      FavoriteModel(3, [0, 1, 2, 3, 4, 5, 6, 7])
    ];
    scrollController = ScrollController();
    controller = EasyRefreshController();

    mData.forEach((e) {
      numbers = numbers + e.data.length;
    });
  }

  @override
  void dispose() {
    super.dispose();

    controller?.dispose();
    scrollController?.dispose();
  }

  void loadData() {
    List<FavoriteModel> testData = [
      FavoriteModel(0, [0, 1, 2, 3, 4, 5]),
      FavoriteModel(1, [0, 1, 2, 3]),
      FavoriteModel(2, [0, 1]),
      FavoriteModel(3, [0, 1, 2, 3, 4, 5, 6, 7]),
      FavoriteModel(4, [0, 1]),
    ];

    Observable.just(testData).delay(Duration(seconds: 2)).listen((event) {
      mData = event;
      mSelectId.clear();

      numbers = 0;
      mData.forEach((e) {
        numbers = numbers + e.data.length;
      });

      setState(() {});
    }, onDone: () {
      controller.finishRefresh();
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
                        "我的收藏（$numbers）",
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
        return Stack(
          children: [
            contentWidget().positionOn(top: 0, bottom: 0, left: 0, right: 0),
            floatWidget().positionOn(
                bottom: MediaQuery.of(context).padding.bottom + 64, right: 16),
          ],
        );
      } else
        return Container(color: Colors.red);
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
          return listItemWidget(index);
        },
        childCount: mData.length,
      ),
    );
  }

  Widget listItemWidget(index) {
    bool hasSelect = mSelectId.contains(mData[index].code);

    return Container(
      child: Column(
        children: [
          Container(
            height: 56,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    index == 0 ? "默认收藏夹" : "收藏夹$index",
                    style: TextStyle(fontSize: 14, color: BaseColor.textDark),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${mData[index].data.length}篇言论",
                  style: TextStyle(color: BaseColor.accent, fontSize: 14),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Visibility(
            visible: hasSelect,
            child: Container(
              child: articleWidget(index),
            ),
          ),
          Container(
            height: 1,
            color: BaseColor.line,
          ),
        ],
      ),
    ).onClick(() {
      if (mSelectId.contains(mData[index].code)) {
        mSelectId.removeWhere((element) => element == mData[index].code);
      } else {
        mSelectId.add(mData[index].code);
      }
      setState(() {});
    });
  }

  Widget articleWidget(index) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeTop: true,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return articleItemWidget(index);
        },
        itemCount: mData[index].data.length,
      ),
    );
  }

  Widget articleItemWidget(index) {
    return Container(
      height: 45,
      child: Column(
        children: [
          Container(
            height: 1,
            color: BaseColor.line,
            margin: EdgeInsets.only(left: 16, right: 16),
          ),
          Container(
            height: 44,
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              index % 2 == 0 ? "今天是个好日子" : "唱支山歌给党听",
              style: TextStyle(fontSize: 13, color: BaseColor.textGray),
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ),
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
    ).onClick(() {
      BaseTool.toast(msg: "添加收藏夹");
    });
  }
}

class FavoriteModel {
  int code;
  List<int> data;

  FavoriteModel(this.code, this.data);
}
