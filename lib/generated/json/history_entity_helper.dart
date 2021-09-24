import 'package:flutter_boss_says/data/entity/history_entity.dart';

historyEntityFromJson(HistoryEntity data, Map<String, dynamic> json) {
	if (json['articleId'] != null) {
		data.articleId = json['articleId'].toString();
	}
	if (json['articleTitle'] != null) {
		data.articleTitle = json['articleTitle'].toString();
	}
	if (json['bossHead'] != null) {
		data.bossHead = json['bossHead'].toString();
	}
	if (json['bossName'] != null) {
		data.bossName = json['bossName'].toString();
	}
	if (json['id'] != null) {
		data.id = json['id'].toString();
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
	if (json['hidden'] != null) {
		data.hidden = json['hidden'];
	}
	return data;
}

Map<String, dynamic> historyEntityToJson(HistoryEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['articleId'] = entity.articleId;
	data['articleTitle'] = entity.articleTitle;
	data['bossHead'] = entity.bossHead;
	data['bossName'] = entity.bossName;
	data['id'] = entity.id;
	data['updateTime'] = entity.updateTime;
	data['createTime'] = entity.createTime;
	data['hidden'] = entity.hidden;
	return data;
}