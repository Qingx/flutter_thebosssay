import 'package:flutter_boss_says/data/entity/article_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';

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
	if (json['descContent'] != null) {
		data.descContent = json['descContent'].toString();
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['isPoint'] != null) {
		data.isPoint = json['isPoint'];
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
		data.bossVO = BossInfoEntity().fromJson(json['bossVO']);
	}
	return data;
}

Map<String, dynamic> articleEntityToJson(ArticleEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['bossId'] = entity.bossId;
	data['title'] = entity.title;
	data['descContent'] = entity.descContent;
	data['isCollect'] = entity.isCollect;
	data['isPoint'] = entity.isPoint;
	data['readCount'] = entity.readCount;
	data['collect'] = entity.collect;
	data['releaseTime'] = entity.releaseTime;
	data['articleTime'] = entity.articleTime;
	data['files'] = entity.files;
	data['bossVO'] = entity.bossVO?.toJson();
	return data;
}