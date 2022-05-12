import 'package:flutter_boss_says/data/entity/daily_entity.dart';

dailyEntityFromJson(DailyEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['bossHead'] != null) {
		data.bossHead = json['bossHead'].toString();
	}
	if (json['bossName'] != null) {
		data.bossName = json['bossName'].toString();
	}
	if (json['bossRole'] != null) {
		data.bossRole = json['bossRole'].toString();
	}
	if (json['content'] != null) {
		data.content = json['content'].toString();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['isPoint'] != null) {
		data.isPoint = json['isPoint'];
	}
	return data;
}

Map<String, dynamic> dailyEntityToJson(DailyEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['bossHead'] = entity.bossHead;
	data['bossName'] = entity.bossName;
	data['bossRole'] = entity.bossRole;
	data['content'] = entity.content;
	data['createTime'] = entity.createTime;
	data['isCollect'] = entity.isCollect;
	data['isPoint'] = entity.isPoint;
	return data;
}