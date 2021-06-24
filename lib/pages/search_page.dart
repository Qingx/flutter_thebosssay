import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/base_page_controller.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
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

    builderFuture = getData();
    concat([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], false);

    scrollController = ScrollController();
    controller = EasyRefreshController();
  }

  @override
  void loadData(bool loadMore) {}

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
                fillColor: BaseColor.loadBg,
                filled: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 24,
                  color: BaseColor.textDark,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (text) {
                Fluttertoast.showToast(msg: text);
                editingController.clear();
              },
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
        return contentWidget();
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
}
