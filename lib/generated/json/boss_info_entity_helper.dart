import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'dart:convert' as convert;

bossInfoEntityFromJson(BossInfoEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['head'] != null) {
		data.head = json['head'].toString();
	}
	if (json['role'] != null) {
		data.role = json['role'].toString();
	}
	if (json['info'] != null) {
		data.info = json['info'].toString();
	}
	if (json['top'] != null) {
		data.top = json['top'];
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['deleted'] != null) {
		data.deleted = json['deleted'];
	}
	if (json['guide'] != null) {
		data.guide = json['guide'];
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
	if (json['updateCount'] != null) {
		data.updateCount = json['updateCount'] is String
				? int.tryParse(json['updateCount'])
				: json['updateCount'].toInt();
	}
	if (json['totalCount'] != null) {
		data.totalCount = json['totalCount'] is String
				? int.tryParse(json['totalCount'])
				: json['totalCount'].toInt();
	}
	if (json['updateTime'] != null) {
		data.updateTime = json['updateTime'] is String
				? int.tryParse(json['updateTime'])
				: json['updateTime'].toInt();
	}
	if (json['labels'] != null) {
		data.labels = (json['labels'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	return data;
}

Map<String, dynamic> bossInfoEntityToJson(BossInfoEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['head'] = entity.head;
	data['role'] = entity.role;
	data['info'] = entity.info;
	data['top'] = entity.top;
	data['isCollect'] = entity.isCollect;
	data['deleted'] = entity.deleted;
	data['guide'] = entity.guide;
	data['readCount'] = entity.readCount;
	data['collect'] = entity.collect;
	data['updateCount'] = entity.updateCount;
	data['totalCount'] = entity.totalCount;
	data['updateTime'] = entity.updateTime;
	data['labels'] = entity.labels;
	return data;
}