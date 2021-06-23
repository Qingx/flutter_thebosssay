import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key key}) : super(key: key);

  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage>
    with AutomaticKeepAliveClientMixin {
  int mCurrentTab = 0;
  var builderFuture;
  ScrollController scrollController;
  GlobalKey<_BodyWidgetState> bodyKey;

  Future<bool> getData() {
    return Observable.just(true).delay(Duration(seconds: 2)).last;
  }

  @override
  void initState() {
    super.initState();
    bodyKey = GlobalKey();

    builderFuture = getData();

    scrollController = ScrollController();
    scrollController.addListener(() {
      bodyKey.currentState.canRefresh = scrollController.position.pixels ==
          scrollController.position.minScrollExtent;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child: NestedScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        headerSliverBuilder: (context, isScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: false,
              toolbarHeight: 227,
              flexibleSpace: topWidget(),
            ),
          ];
        },
        body: BodyWidget([0, 1, 2, 3, 4, 5, 6, 7, 8], bodyKey),
      ),
    );
  }

  Widget testBodyWidget() {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            color: Colors.primaries[index % Colors.primaries.length],
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          );
        },
        itemCount: 32,
      ),
    );
  }

  Widget topWidget() {
    return Container(
      color: BaseColor.pageBg,
      child: Column(
        children: [
          tabWidget(),
          cardWidget(),
          titleWidget(),
        ],
      ),
    );
  }

  Widget tabWidget() {
    return Container(
      height: 28,
      margin: EdgeInsets.only(top: 12),
      child: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return tabItemWidget(index);
          },
          itemCount: 16,
        ),
      ),
    );
  }

  Widget tabItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;
    Color bgColor =
        mCurrentTab == index ? BaseColor.accent : BaseColor.accentLight;
    Color fontColor = mCurrentTab == index ? Colors.white : BaseColor.accent;
    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      padding: EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14)), color: bgColor),
      child: Center(
        child: Text(
          index % 2 == 0 ? "全部" : "职业作者",
          style: TextStyle(color: fontColor, fontSize: 14),
        ),
      ),
    ).onClick(() {
      setState(() {});
    });
  }

  Widget cardWidget() {
    return Container(
      height: 164,
      child: MediaQuery.removePadding(
        removeBottom: true,
        removeTop: true,
        context: context,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return cardItemWidget(index);
          },
          itemCount: 12,
        ),
      ),
    );
  }

  Widget cardItemWidget(int index) {
    double left = index == 0 ? 16 : 8;
    double right = index == 15 ? 16 : 8;

    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.only(left: left, right: right, top: 24),
      child: Center(
        child: Text("哈利路亚"),
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 12, top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "最近更新",
            style: TextStyle(
                color: BaseColor.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ).marginOn(left: 16),
          Text(
            "共25篇",
            style: TextStyle(color: BaseColor.textDark, fontSize: 14),
          ).marginOn(left: 16)
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BodyWidget extends StatefulWidget {
  List<int> initData;

  BodyWidget(this.initData, Key key) : super(key: key);

  @override
  _BodyWidgetState createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> with BasePageController<int> {
  ScrollController scrollController;
  bool canRefresh;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: ListView.builder(
        controller: scrollController,
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return itemWidget(index);
        },
        itemCount: mData.length,
      ),
    );
  }

  Widget itemWidget(int index) {
    return Container(
      height: 80,
      color: Colors.primaries[index % Colors.primaries.length],
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    concat(widget.initData, false);

    scrollController = ScrollController();
    scrollController.addListener(() {
      var current = scrollController.position.pixels;
      var min = scrollController.position.minScrollExtent;
      var max = scrollController.position.maxScrollExtent;

      if (current == min && canRefresh) {
        Fluttertoast.showToast(msg: "refresh");
        // bodyKey.currentState.loadData(false);
        loadData(false);
      }

      if (current == max) {
        Fluttertoast.showToast(msg: "refresh");
        // bodyKey.currentState.loadData(true);
        loadData(true);
      }
    });
  }

  @override
  void loadData(bool loadMore) {
    if (!loadMore) {
      pageParam.reset();
    }

    Observable.just([0, 1, 2, 3, 4, 5, 6])
        .delay(Duration(seconds: 2))
        .listen((event) {
      concat(event, loadMore);
      setState(() {});
    });
  }
}
