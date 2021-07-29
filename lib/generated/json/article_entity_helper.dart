import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'dart:convert' as convert;

articleEntityFromJson(ArticleEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['bossId'] != null) {
		data.bossId = json['bossId'].toString();
	}
	if (json['title'] != null) {
		data.title = json['title'].toString();
	}
	if (json['content'] != null) {
		data.content = json['content'].toString();
	}
	if (json['descContent'] != null) {
		data.descContent = json['descContent'].toString();
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['isPoint'] != null) {
		data.isPoint = json['isPoint'];
	}
	if (json['point'] != null) {
		data.point = json['point'] is String
				? int.tryParse(json['point'])
				: json['point'].toInt();
	}
	if (json['collect'] != null) {
		data.collect = json['collect'] is String
				? int.tryParse(json['collect'])
				: json['collect'].toInt();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	if (json['status'] != null) {
		data.status = json['status'] is String
				? int.tryParse(json['status'])
				: json['status'].toInt();
	}
	if (json['files'] != null) {
		data.files = (json['files'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	if (json['originLink'] != null) {
		data.originLink = json['originLink'].toString();
	}
	if (json['bossVO'] != null) {
		data.bossVO = BossInfoEntity().fromJson(json['bossVO']);
	}
	return data;
}

Map<String, dynamic> articleEntityToJson(ArticleEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['bossId'] = entity.bossId;
	data['title'] = entity.title;
	data['content'] = entity.content;
	data['descContent'] = entity.descContent;
	data['isCollect'] = entity.isCollect;
	data['isPoint'] = entity.isPoint;
	data['point'] = entity.point;
	data['collect'] = entity.collect;
	data['createTime'] = entity.createTime;
	data['status'] = entity.status;
	data['files'] = entity.files;
	data['originLink'] = entity.originLink;
	data['bossVO'] = entity.bossVO?.toJson();
	return data;
}