import 'package:flutter_boss_says/data/entity/his_fav_entity.dart';
import 'package:flutter_boss_says/data/entity/daily_entity.dart';

hisFavEntityFromJson(HisFavEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['articleId'] != null) {
		data.articleId = json['articleId'].toString();
	}
	if (json['content'] != null) {
		data.content = json['content'].toString();
	}
	if (json['bossHead'] != null) {
		data.bossHead = json['bossHead'].toString();
	}
	if (json['bossName'] != null) {
		data.bossName = json['bossName'].toString();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	if (json['articleType'] != null) {
		data.articleType = json['articleType'].toString();
	}
	if (json['type'] != null) {
		data.type = json['type'].toString();
	}
	if (json['hidden'] != null) {
		data.hidden = json['hidden'];
	}
	if (json['bossRole'] != null) {
		data.bossRole = json['bossRole'].toString();
	}
	if (json['isCollect'] != null) {
		data.isCollect = json['isCollect'];
	}
	if (json['isPoint'] != null) {
		data.isPoint = json['isPoint'];
	}
	if (json['cover'] != null) {
		data.cover = json['cover'].toString();
	}
	return data;
}

Map<String, dynamic> hisFavEntityToJson(HisFavEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['articleId'] = entity.articleId;
	data['content'] = entity.content;
	data['bossHead'] = entity.bossHead;
	data['bossName'] = entity.bossName;
	data['createTime'] = entity.createTime;
	data['articleType'] = entity.articleType;
	data['type'] = entity.type;
	data['hidden'] = entity.hidden;
	data['bossRole'] = entity.bossRole;
	data['isCollect'] = entity.isCollect;
	data['isPoint'] = entity.isPoint;
	data['cover'] = entity.cover;
	return data;
}