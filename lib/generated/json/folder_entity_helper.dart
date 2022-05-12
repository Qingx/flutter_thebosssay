import 'package:flutter_boss_says/data/entity/folder_entity.dart';

folderEntityFromJson(FolderEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['cover'] != null) {
		data.cover = json['cover'].toString();
	}
	if (json['articleCount'] != null) {
		data.articleCount = json['articleCount'] is String
				? int.tryParse(json['articleCount'])
				: json['articleCount'].toInt();
	}
	if (json['bossCount'] != null) {
		data.bossCount = json['bossCount'] is String
				? int.tryParse(json['bossCount'])
				: json['bossCount'].toInt();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	return data;
}

Map<String, dynamic> folderEntityToJson(FolderEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['cover'] = entity.cover;
	data['articleCount'] = entity.articleCount;
	data['bossCount'] = entity.bossCount;
	data['createTime'] = entity.createTime;
	return data;
}