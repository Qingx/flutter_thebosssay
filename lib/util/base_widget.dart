import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BaseWidget {
  ///状态栏
  static Widget statusBar(BuildContext context, bool withTrans) {
    double _statusBarHeight = MediaQuery.of(context).padding.top; //状态栏高度
    Color _backgroundColor = withTrans ? Colors.transparent : Colors.white;

    return Container(
      height: _statusBarHeight,
      color: _backgroundColor,
    );
  }

  static Widget emptyWidget(String path, String content) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 200, height: 200),
            Flexible(
                child: Text(content,
                    style: TextStyle(fontSize: 18, color: BaseColor.line),
                    textAlign: TextAlign.center))
          ],
        ),
      ),
    );
  }

  static Widget loadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: SpinKitFadingCircle(
            color: BaseColor.accent,
            size: 50,
            duration: Duration(milliseconds: 2000),
          ),
        )
      ],
    ));
  }

  static Widget testItemWidget(int index) {
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

  static EasyRefresh refreshWidgetPage(
      {List<Widget> slivers,
      EasyRefreshController controller,
      ScrollController scrollController,
      bool hasData,
      Function(bool) loadData}) {
    return EasyRefresh.custom(
      enableControlFinishRefresh: true,
      enableControlFinishLoad: true,
      taskIndependence: false,
      controller: controller,
      scrollController: scrollController,
      scrollDirection: Axis.vertical,
      topBouncing: true,
      bottomBouncing: true,
      header: ClassicalHeader(
        enableInfiniteRefresh: false,
        bgColor: null,
        infoColor: BaseColor.textDark,
        float: false,
        enableHapticFeedback: true,
        refreshText: "下拉以刷新",
        refreshReadyText: "释放以刷新",
        refreshingText: "正在刷新",
        refreshedText: "刷新完成",
        refreshFailedText: "刷新失败",
        noMoreText: "没有更多数据了",
        infoText: "上次更新 %T",
      ),
      footer: ClassicalFooter(
        enableInfiniteLoad: true,
        enableHapticFeedback: true,
        infoColor: BaseColor.textDark,
        loadText: "上拉以加载",
        loadReadyText: "释放以加载",
        loadingText: "正在加载",
        loadedText: "加载完成",
        loadFailedText: "加载失败",
        noMoreText: "没有更多数据了",
        infoText: "上次更新 %T",
      ),
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 0), () {
          loadData(false);
        });
      },
      onLoad: hasData
          ? () async {
              await Future.delayed(Duration(seconds: 0), () {
                loadData(true);
              });
            }
          : null,
      slivers: slivers,
    );
  }

  static EasyRefresh refreshWidget(
      {List<Widget> slivers,
      EasyRefreshController controller,
      ScrollController scrollController,
      Function loadData}) {
    return EasyRefresh.custom(
      enableControlFinishRefresh: true,
      taskIndependence: false,
      controller: controller,
      scrollController: scrollController,
      scrollDirection: Axis.vertical,
      topBouncing: true,
      bottomBouncing: true,
      header: ClassicalHeader(
        enableInfiniteRefresh: false,
        bgColor: null,
        infoColor: BaseColor.textDark,
        float: false,
        enableHapticFeedback: true,
        refreshText: "下拉以刷新",
        refreshReadyText: "释放以刷新",
        refreshingText: "正在刷新",
        refreshedText: "刷新完成",
        refreshFailedText: "刷新失败",
        noMoreText: "没有更多数据了",
        infoText: "上次更新 %T",
      ),
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 0), () {
          loadData();
        });
      },
      slivers: slivers,
    );
  }

  static Future<dynamic> showLoadingAlert(String notice, BuildContext context) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 80,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SpinKitFadingCircle(
                    color: BaseColor.accent,
                    size: 32,
                    duration: Duration(milliseconds: 2000),
                  ).marginOn(left: 16),
                  Text(
                    notice,
                    style: TextStyle(color: BaseColor.textDark, fontSize: 16),
                    textAlign: TextAlign.start,
                  ).marginOn(left: 12)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
