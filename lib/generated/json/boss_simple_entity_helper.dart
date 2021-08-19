import 'package:flutter_boss_says/data/model/boss_simple_entity.dart';
import 'package:flutter_boss_says/util/base_tool.dart';

bossSimpleEntityFromJson(BossSimpleEntity data, Map<String, dynamic> json) {
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
	if (json['top'] != null) {
		data.top = json['top'];
	}
	if (json['updateTime'] != null) {
		data.updateTime = json['updateTime'] is String
				? int.tryParse(json['updateTime'])
				: json['updateTime'].toInt();
	}
	if (json['labels'] != null) {
		data.labels = (json['labels'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	if (json['photoUrl'] != null) {
		data.photoUrl = (json['photoUrl'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	return data;
}

Map<String, dynamic> bossSimpleEntityToJson(BossSimpleEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['head'] = entity.head;
	data['role'] = entity.role;
	data['top'] = entity.top;
	data['updateTime'] = entity.updateTime;
	data['labels'] = entity.labels;
	data['photoUrl'] = entity.photoUrl;
	return data;
}