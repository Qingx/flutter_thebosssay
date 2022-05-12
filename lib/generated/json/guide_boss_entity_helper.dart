import 'package:flutter_boss_says/data/entity/guide_boss_entity.dart';

guidBossEntityFromJson(GuidBossEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['role'] != null) {
		data.role = json['role'].toString();
	}
	if (json['head'] != null) {
		data.head = json['head'].toString();
	}
	if (json['photoUrl'] != null) {
		data.photoUrl = (json['photoUrl'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	return data;
}

Map<String, dynamic> guidBossEntityToJson(GuidBossEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['role'] = entity.role;
	data['head'] = entity.head;
	data['photoUrl'] = entity.photoUrl;
	return data;
}