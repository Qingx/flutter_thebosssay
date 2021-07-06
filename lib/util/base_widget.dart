import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_boss_says/util/base_extension.dart';

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

  ///含正文 纯文字
  static Widget onlyTextWithContent(int index, BuildContext context) {
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    String head = R.assetsImgTestHead;
    String content =
        "领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原…";

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            height: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  "莉莉娅",
                  style:
                      TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 8),
                Expanded(
                  child: Text(
                    "灵魂莲华灵魂莲华灵魂莲华灵魂莲华",
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(left: 8),
                ),
              ],
            ),
          ),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
            textAlign: TextAlign.start,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ).marginOn(top: 8),
          Container(
            margin: EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "8.2k收藏·19.9w人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "2020/03/02",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget followItem(
      ArticleEntity entity, int index, BuildContext context) {
    String head = index % 2 == 0 ? R.assetsImgTestHead : R.assetsImgTestPhoto;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entity.title,
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            height: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                    child: Image.network(
                  HttpConfig.fullUrl(entity.bossVO.head),
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      head,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    );
                  },
                )),
                Text(
                  entity.bossVO.name,
                  style:
                      TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(left: 8),
                Expanded(
                  child: Text(
                    entity.bossVO.role,
                    style: TextStyle(fontSize: 14, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ).marginOn(left: 8),
                ),
              ],
            ),
          ),
          Text(
            "entity.content",
            style: TextStyle(fontSize: 14, color: BaseColor.textDarkLight),
            textAlign: TextAlign.start,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ).marginOn(top: 8),
          Container(
            margin: EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${entity.collect}k收藏·${entity.point}w人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat.getYYYYMMDD(entity.createTime),
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///含正文 单个图片文字
  static Widget singleImgWithContent(int index, BuildContext context) {
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";
    String head = R.assetsImgTestPhoto;
    String content =
        "领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原领效电提算场已将铁存它色置识种是量性传周么名光却次种中节志至或局会点再部技七条先位记建政原…";

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            height: 72,
            margin: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              "莉莉娅",
                              style: TextStyle(
                                  fontSize: 14, color: BaseColor.textDarkLight),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(left: 8),
                            Expanded(
                              child: Text(
                                "灵魂莲华灵魂莲华灵魂莲华灵魂莲华",
                                style: TextStyle(
                                    fontSize: 14, color: BaseColor.textGray),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ).marginOn(left: 8),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        content,
                        style: TextStyle(
                            fontSize: 14, color: BaseColor.textDarkLight),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    R.assetsImgTestHead,
                    width: 96,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ).marginOn(left: 16),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "8.2k收藏·19.9w人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "2020/03/02",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///无正文 三个图片文字
  static Widget adTriImgNoContent(int index, BuildContext context) {
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: BaseColor.textDark,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            height: 80,
            child: MediaQuery.removePadding(
              removeBottom: true,
              removeTop: true,
              context: context,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 4,
                  childAspectRatio:
                      (MediaQuery.of(context).size.width - 28 - 8) / 3 / 80,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      R.assetsImgTestHead,
                      height: 80,
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            "广告·海南万科",
            style: TextStyle(fontSize: 13, color: BaseColor.textGray),
            textAlign: TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ).marginOn(top: 16),
        ],
      ),
    );
  }

  ///无正文 单个图片文字
  static Widget singleImgNoContent(int index, BuildContext context) {
    String title = "搞什么副业可以月入过万搞什么副业可以月入过万搞什么副业可以月入过万";

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: BaseColor.textDark,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "烽火崛起·19.9w人围观·6小时前",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 16),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              R.assetsImgTestPhoto,
              width: 96,
              height: 64,
              fit: BoxFit.cover,
            ),
          ).marginOn(left: 16),
        ],
      ),
    );
  }
}
