import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_widget.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

class ArticlePage extends StatefulWidget {
  const ArticlePage({Key key}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String articleId;

  var builderFuture;

  ScrollController scrollController;

  void onShare() {
    Share.share('https://www.bilibili.com/');
  }

  void onFavorite() {}

  @override
  void initState() {
    super.initState();

    articleId = Get.arguments as String;

    scrollController = ScrollController();

    builderFuture = loadInitData();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
  }

  Future<bool> loadInitData() {
    return Observable.just(true).delay(Duration(milliseconds: 1600)).last;
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: BaseColor.textDark,
                    size: 28,
                  ).onClick(() {
                    Get.back();
                  }),
                  Expanded(child: SizedBox()),
                  Image.asset(R.assetsImgFavoriteDark, width: 24, height: 24)
                      .marginOn(right: 20)
                      .onClick(onFavorite),
                  Image.asset(R.assetsImgShareDark, width: 24, height: 24)
                      .marginOn(right: 16)
                      .onClick(onShare),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                builder: builderWidget,
                future: builderFuture,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget builderWidget(BuildContext context, AsyncSnapshot snapshot) {
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
    return MediaQuery.removePadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: ListView(
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.vertical,
        controller: scrollController,
        children: [
          Text(
            "这里是新闻的标题这里是新闻的标题这里是新闻的标题这里是新闻的标题这里是新闻的标题这里是新闻的标题这里是新闻的标题这里是新闻的标题",
            style: TextStyle(
              fontSize: 18,
              color: BaseColor.textDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "2348 收藏·1.1w 浏览",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(child: SizedBox()),
                Icon(
                  Icons.access_time,
                  color: BaseColor.textGray,
                  size: 14,
                ).marginOn(right: 4),
                Text(
                  "9小时前",
                  style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          bossWidget(),
          bodyWidget(),
        ],
      ),
    );
  }

  Widget bossWidget() {
    bool hasFollow = true;
    return Container(
      height: 64,
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              HttpConfig.fullUrl("entity.bossVO?.head"),
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  R.assetsImgTestPhoto,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12, right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "任振飞",
                        style: TextStyle(
                            color: BaseColor.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        softWrap: false,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Image.asset(
                        R.assetsImgBossLabel,
                        width: 56,
                        height: 16,
                      ).marginOn(left: 8)
                    ],
                  ),
                  Text(
                    "华为创始人",
                    style: TextStyle(
                      color: BaseColor.textGray,
                      fontSize: 10,
                    ),
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 32,
            padding: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: hasFollow ? BaseColor.loadBg : BaseColor.accent,
            ),
            child: hasFollow
                ? Text(
                    "已追踪",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    softWrap: false,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                      Text(
                        "追踪TA",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ).marginOn(left: 4),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Widget bodyWidget() {
    String document="""<p>312321321321<strong>123232132112332132112312321321</strong>123<span style="color: #ff0000;">123231321321<em>12321321321<span style="text-decoration: underline;">231231321231<img src="https://cdn.jsdelivr.net/npm/tinymce-all-in-one@4.9.3/plugins/emoticons/img/smiley-smile.gif" alt="smile" /></span></em></span></p >""";
    return Container(
      child: Html(
        data: document,
      ),
    );
  }
}
