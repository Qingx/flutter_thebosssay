import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';

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
	if (json['date'] != null) {
		data.date = json['date'] is String
				? int.tryParse(json['date'])
				: json['date'].toInt();
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['isPoint'] != null) {
		data.isPoint = json['isPoint'];
	}
	if (json['deleted'] != null) {
		data.deleted = json['deleted'];
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
	if (json['readCount'] != null) {
		data.readCount = json['readCount'] is String
				? int.tryParse(json['readCount'])
				: json['readCount'].toInt();
	}
	if (json['updateTime'] != null) {
		data.updateTime = json['updateTime'] is String
				? int.tryParse(json['updateTime'])
				: json['updateTime'].toInt();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
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
	data['date'] = entity.date;
	data['isCollect'] = entity.isCollect;
	data['isPoint'] = entity.isPoint;
	data['deleted'] = entity.deleted;
	data['point'] = entity.point;
	data['collect'] = entity.collect;
	data['updateCount'] = entity.updateCount;
	data['totalCount'] = entity.totalCount;
	data['readCount'] = entity.readCount;
	data['updateTime'] = entity.updateTime;
	data['createTime'] = entity.createTime;
	return data;
}