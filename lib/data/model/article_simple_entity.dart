import 'dart:convert' as convert;

import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'package:flutter_boss_says/util/base_extension.dart';
import 'package:flutter_boss_says/util/base_tool.dart';

class ArticleSimpleEntity with JsonConvert<ArticleSimpleEntity> {
  String id; //id
  String title; //标题
  String descContent = ""; //摘要
  bool isCollect = false; //是否收藏
  bool isRead = false; //是否已读
  bool isPoint = false; //是否点赞
  int readCount = 0; //阅读数
  int collect = 0; //收藏数
  int point = 0; //点赞数
  int releaseTime = 0; //发布时间
  int articleTime = 0; //文章时间
  List<String> files = []; //图片列表
  String bossId; //bossId
  String bossName; //boss名
  String bossHead = ""; //boss头像
  String bossRole; //boss角色, 职务
  String recommendType; //0:最近更新 1:为你推荐
  String filterType; //1:言论 2：资讯

  int getShowTime() {
    return releaseTime ?? articleTime;
  }

  bool isLatest() {
    return BaseTool.inThreeDays(getShowTime()) && !isRead;
  }

  bool inThreeDays() {
    return BaseTool.inThreeDays(getShowTime());
  }

  @override
  String toString() {
    return 'ArticleSimpleEntity{id: $id, title: $title, descContent: $descContent, isCollect: $isCollect, isRead: $isRead, isPoint: $isPoint, readCount: $readCount, collect: $collect, point: $point, releaseTime: $releaseTime, articleTime: $articleTime, files: $files, bossId: $bossId, bossName: $bossName, bossHead: $bossHead, bossRole: $bossRole, recommendType: $recommendType, filterType: $filterType}';
  }
}
