import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/pages/web_article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';
import 'package:get/get.dart';

class ArticleWidget {
  ///含正文 纯文字
  static Widget onlyTextWithContent(
      ArticleEntity entity, BuildContext context) {
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
                fontSize: 18,
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
                    HttpConfig.fullUrl(entity.bossVO?.head),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        R.assetsImgDefaultHead,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
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
            entity.descContent,
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
                    "${entity.collect.formatCountNumber()}收藏·${entity.readCount.formatCountNumber()}人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  BaseTool.getArticleItemTime(entity.getShowTime()),
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
    ).onClick(() {
      Get.to(() => WebArticlePage(), arguments: entity.id);
    });
  }

  ///含正文 单个图片文字
  static Widget singleImgWithContent(
      ArticleEntity entity, BuildContext context) {
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
                fontSize: 18,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                HttpConfig.fullUrl(entity.bossVO?.head),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    R.assetsImgDefaultHead,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Text(
                              entity.bossVO.name,
                              style: TextStyle(
                                  fontSize: 14, color: BaseColor.textDarkLight),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(left: 8),
                            Expanded(
                              child: Text(
                                entity.bossVO.role,
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
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entity.descContent,
                            style: TextStyle(
                                fontSize: 14, color: BaseColor.textDarkLight),
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    HttpConfig.fullUrl(entity.files[0]),
                    width: 96,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        R.assetsImgDefaultCover,
                        width: 96,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    },
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
                    "${entity.collect.formatCountNumber()}收藏·${entity.readCount.formatCountNumber()}人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  BaseTool.getArticleItemTime(entity.getShowTime()),
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
    ).onClick(() {
      Get.to(() => WebArticlePage(), arguments: entity.id);
    });
  }

  ///无正文 纯文字
  static Widget onlyTextNoContent(ArticleEntity entity, BuildContext context) {
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
                fontSize: 18,
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
                    HttpConfig.fullUrl(entity.bossVO?.head),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        R.assetsImgDefaultHead,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
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
          Container(
            margin: EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${entity.collect.formatCountNumber()}收藏·${entity.readCount.formatCountNumber()}人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  BaseTool.getArticleItemTime(entity.getShowTime()),
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
    ).onClick(() {
      Get.to(() => WebArticlePage(), arguments: entity.id);
    });
  }

  ///无正文 单个图片文字
  static Widget singleImgNoContent(ArticleEntity entity, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              entity.title,
              style: TextStyle(
                  fontSize: 18,
                  color: BaseColor.textDark,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                HttpConfig.fullUrl(entity.bossVO?.head),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    R.assetsImgDefaultHead,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Text(
                              entity.bossVO.name,
                              style: TextStyle(
                                  fontSize: 14, color: BaseColor.textDarkLight),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(left: 8),
                            Expanded(
                              child: Text(
                                entity.bossVO.role,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "${entity.collect.formatCountNumber()}收藏·${entity.readCount.formatCountNumber()}人围观",
                                style: TextStyle(
                                    fontSize: 13, color: BaseColor.textGray),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              BaseTool.getArticleItemTime(entity.getShowTime()),
                              style: TextStyle(
                                  fontSize: 13, color: BaseColor.textGray),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    HttpConfig.fullUrl(entity.files[0]),
                    width: 96,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        R.assetsImgDefaultCover,
                        width: 96,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ).marginOn(left: 8)
              ],
            ),
          )
        ],
      ),
    ).onClick(() {
      Get.to(() => WebArticlePage(), arguments: entity.id);
    });
  }

  ///含正文 纯文字 BossPage
  static Widget onlyTextWithContentBossPage(
      ArticleEntity entity, BuildContext context, Function doItemClick) {
    bool isRead = entity.isRead;
    Color bgColor = isRead ? BaseColor.loadBg : Colors.white;
    bool isShowRed = BaseTool.showRedDots(entity.bossId, entity.getShowTime());

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Stack(
              children: [
                Text(
                  entity.title,
                  style: TextStyle(
                      fontSize: 18,
                      color: BaseColor.textDark,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 16),
                isRead
                    ? SizedBox()
                    : isShowRed
                        ? Container(
                            padding: EdgeInsets.only(
                                left: 4, right: 4, top: 2, bottom: 2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                              color: Colors.red,
                            ),
                            child: Text(
                              "最近更新",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ).positionOn(right: 0)
                        : SizedBox(),
              ],
            ),
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
                    HttpConfig.fullUrl(entity.bossVO?.head),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        R.assetsImgDefaultHead,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
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
            entity.descContent,
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
                    "${entity.collect.formatCountNumber()}收藏·${entity.readCount.formatCountNumber()}人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  BaseTool.getArticleItemTime(entity.getShowTime()),
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
    ).onClick(doItemClick);
  }

  ///含正文 单个图片文字 BossPage
  static Widget singleImgWithContentBossPage(
      ArticleEntity entity, BuildContext context, Function doItemClick) {
    bool isRead = entity.isRead;
    Color bgColor = isRead ? BaseColor.loadBg : Colors.white;
    bool isShowRed = BaseTool.showRedDots(entity.bossId, entity.getShowTime());

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Stack(
              children: [
                Text(
                  entity.title,
                  style: TextStyle(
                      fontSize: 18,
                      color: BaseColor.textDark,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).marginOn(top: 16),
                isRead
                    ? SizedBox()
                    : isShowRed
                        ? Container(
                            padding: EdgeInsets.only(
                                left: 4, right: 4, top: 2, bottom: 2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                              color: Colors.red,
                            ),
                            child: Text(
                              "最近更新",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ).positionOn(right: 0)
                        : SizedBox(),
              ],
            ),
          ),
          Container(
            height: 72,
            margin: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                HttpConfig.fullUrl(entity.bossVO?.head),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    R.assetsImgDefaultHead,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Text(
                              entity.bossVO.name,
                              style: TextStyle(
                                  fontSize: 14, color: BaseColor.textDarkLight),
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ).marginOn(left: 8),
                            Expanded(
                              child: Text(
                                entity.bossVO.role,
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
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entity.descContent,
                            style: TextStyle(
                                fontSize: 14, color: BaseColor.textDarkLight),
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    HttpConfig.fullUrl(entity.files[0]),
                    width: 96,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        R.assetsImgDefaultCover,
                        width: 96,
                        height: 64,
                        fit: BoxFit.cover,
                      );
                    },
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
                    "${entity.collect.formatCountNumber()}收藏·${entity.readCount.formatCountNumber()}人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  BaseTool.getArticleItemTime(entity.getShowTime()),
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
    ).onClick(doItemClick);
  }
}
