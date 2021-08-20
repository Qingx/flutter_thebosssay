import 'package:flutter_boss_says/data/model/article_simple_entity.dart';
import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'dart:convert' as convert;

articleSimpleEntityFromJson(ArticleSimpleEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['title'] != null) {
		data.title = json['title'].toString();
	}
	if (json['descContent'] != null) {
		data.descContent = json['descContent'].toString();
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['isRead'] != null) {
		data.isRead = json['isRead'];
	}
	if (json['readCount'] != null) {
		data.readCount = json['readCount'] is String
				? int.tryParse(json['readCount'])
				: json['readCount'].toInt();
	}
	if (json['collect'] != null) {
		data.collect = json['collect'] is String
				? int.tryParse(json['collect'])
				: json['collect'].toInt();
	}
	if (json['releaseTime'] != null) {
		data.releaseTime = json['releaseTime'] is String
				? int.tryParse(json['releaseTime'])
				: json['releaseTime'].toInt();
	}
	if (json['articleTime'] != null) {
		data.articleTime = json['articleTime'] is String
				? int.tryParse(json['articleTime'])
				: json['articleTime'].toInt();
	}
	if (json['files'] != null) {
		data.files = (json['files'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	if (json['bossVO'] != null) {
		data.bossVO = BossSimpleEntity().fromJson(json['bossVO']);
	}
	return data;
}

Map<String, dynamic> articleSimpleEntityToJson(ArticleSimpleEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['descContent'] = entity.descContent;
	data['isCollect'] = entity.isCollect;
	data['isRead'] = entity.isRead;
	data['readCount'] = entity.readCount;
	data['collect'] = entity.collect;
	data['releaseTime'] = entity.releaseTime;
	data['articleTime'] = entity.articleTime;
	data['files'] = entity.files;
	data['bossVO'] = entity.bossVO?.toJson();
	return data;
}