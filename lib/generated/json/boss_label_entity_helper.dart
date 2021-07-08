import 'package:flutter_boss_says/data/entity/boss_label_entity.dart';

bossLabelEntityFromJson(BossLabelEntity data, Map<String, dynamic> json) {
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['keyValue'] != null) {
		data.keyValue = json['keyValue'].toString();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['parentId'] != null) {
		data.parentId = json['parentId'].toString();
	}
	if (json['sort'] != null) {
		data.sort = json['sort'] is String
				? int.tryParse(json['sort'])
				: json['sort'].toInt();
	}
	if (json['type'] != null) {
		data.type = json['type'] is String
				? int.tryParse(json['type'])
				: json['type'].toInt();
	}
	return data;
}

Map<String, dynamic> bossLabelEntityToJson(BossLabelEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['createTime'] = entity.createTime;
	data['id'] = entity.id;
	data['keyValue'] = entity.keyValue;
	data['name'] = entity.name;
	data['parentId'] = entity.parentId;
	data['sort'] = entity.sort;
	data['type'] = entity.type;
	return data;
}