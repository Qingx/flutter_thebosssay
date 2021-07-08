import 'package:flutter_boss_says/data/entity/boss_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';

bossEntityFromJson(BossEntity data, Map<String, dynamic> json) {
	if (json['current'] != null) {
		data.current = json['current'] is String
				? int.tryParse(json['current'])
				: json['current'].toInt();
	}
	if (json['hitCount'] != null) {
		data.hitCount = json['hitCount'];
	}
	if (json['pages'] != null) {
		data.pages = json['pages'] is String
				? int.tryParse(json['pages'])
				: json['pages'].toInt();
	}
	if (json['records'] != null) {
		data.records = (json['records'] as List).map((v) => BossInfoEntity().fromJson(v)).toList();
	}
	if (json['searchCount'] != null) {
		data.searchCount = json['searchCount'];
	}
	if (json['size'] != null) {
		data.size = json['size'] is String
				? int.tryParse(json['size'])
				: json['size'].toInt();
	}
	if (json['total'] != null) {
		data.total = json['total'] is String
				? int.tryParse(json['total'])
				: json['total'].toInt();
	}
	return data;
}

Map<String, dynamic> bossEntityToJson(BossEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['current'] = entity.current;
	data['hitCount'] = entity.hitCount;
	data['pages'] = entity.pages;
	data['records'] =  entity.records.map((v) => v.toJson()).toList();
	data['searchCount'] = entity.searchCount;
	data['size'] = entity.size;
	data['total'] = entity.total;
	return data;
}