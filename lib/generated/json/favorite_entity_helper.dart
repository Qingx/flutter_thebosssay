import 'package:flutter_boss_says/data/entity/favorite_entity.dart';
import 'package:flutter_boss_says/data/entity/article_entity.dart';

favoriteEntityFromJson(FavoriteEntity data, Map<String, dynamic> json) {
	if (json['count'] != null) {
		data.count = json['count'] is String
				? int.tryParse(json['count'])
				: json['count'].toInt();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['list'] != null) {
		data.list = (json['list'] as List).map((v) => ArticleEntity().fromJson(v)).toList();
	}
	if (json['name'] != null) {
		data.name = json['name'].toString();
	}
	if (json['userId'] != null) {
		data.userId = json['userId'].toString();
	}
	return data;
}

Map<String, dynamic> favoriteEntityToJson(FavoriteEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['count'] = entity.count;
	data['createTime'] = entity.createTime;
	data['id'] = entity.id;
	data['list'] =  entity.list.map((v) => v.toJson()).toList();
	data['name'] = entity.name;
	data['userId'] = entity.userId;
	return data;
}