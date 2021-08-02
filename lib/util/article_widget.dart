import 'package:flutter/material.dart';
import 'package:flutter_boss_says/config/http_config.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/pages/article_page.dart';
import 'package:flutter_boss_says/r.dart';
import 'package:flutter_boss_says/util/base_color.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/date_format.dart';
import 'package:get/get.dart';

class ArticleWidget {
  ///含正文 纯文字
  static Widget onlyTextWithContent(
      ArticleEntity entity, int index, BuildContext context) {
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
                        R.assetsImgTestPhoto,
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
                    "${entity.collect ?? 0}k收藏·${entity.point ?? 0}w人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat.getYYYYMMDD(entity.releaseTime),
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
      Get.to(() => ArticlePage(), arguments: entity.id);
    });
  }

  ///含正文 单个图片文字
  static Widget singleImgWithContent(
      ArticleEntity entity, int index, BuildContext context) {
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
                                    R.assetsImgTestPhoto,
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
                        R.assetsImgTestPhoto,
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
                    "${entity.collect}k收藏·${entity.point}w人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat.getYYYYMMDD(entity.releaseTime),
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
      Get.to(() => ArticlePage(), arguments: entity.id);
    });
  }

  ///无正文 纯文字
  static Widget onlyTextNoContent(
      ArticleEntity entity, int index, BuildContext context) {
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
                        R.assetsImgTestPhoto,
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
                    "${entity.collect ?? 0}k收藏·${entity.point ?? 0}w人围观",
                    style: TextStyle(fontSize: 13, color: BaseColor.textGray),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat.getYYYYMMDD(entity.releaseTime),
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
      Get.to(() => ArticlePage(), arguments: entity.id);
    });
  }

  ///无正文 单个图片文字
  static Widget singleImgNoContent(
      ArticleEntity entity, int index, BuildContext context) {
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
                                    R.assetsImgTestPhoto,
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
                                "${entity.collect}k收藏·${entity.point}w人围观",
                                style: TextStyle(
                                    fontSize: 13, color: BaseColor.textGray),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${DateFormat.getYYYYMMDD(entity.releaseTime)}",
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
                        R.assetsImgTestPhoto,
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
      Get.to(() => ArticlePage(), arguments: entity.id);
    });
  }
}
