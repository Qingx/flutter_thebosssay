import 'package:flutter_boss_says/test/test_boss_info_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';

testBossInfoEntityFromJson(TestBossInfoEntity data, Map<String, dynamic> json) {
	if (json['size'] != null) {
		data.size = json['size'] is String
				? int.tryParse(json['size'])
				: json['size'].toInt();
	}
	if (json['pages'] != null) {
		data.pages = json['pages'] is String
				? int.tryParse(json['pages'])
				: json['pages'].toInt();
	}
	if (json['total'] != null) {
		data.total = json['total'] is String
				? int.tryParse(json['total'])
				: json['total'].toInt();
	}
	if (json['current'] != null) {
		data.current = json['current'] is String
				? int.tryParse(json['current'])
				: json['current'].toInt();
	}
	if (json['searchCount'] != null) {
		data.searchCount = json['searchCount'];
	}
	if (json['records'] != null) {
		data.records = (json['records'] as List).map((v) => BossInfoEntity().fromJson(v)).toList();
	}
	return data;
}

Map<String, dynamic> testBossInfoEntityToJson(TestBossInfoEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['size'] = entity.size;
	data['pages'] = entity.pages;
	data['total'] = entity.total;
	data['current'] = entity.current;
	data['searchCount'] = entity.searchCount;
	data['records'] =  entity.records?.map((v) => v.toJson())?.toList();
	return data;
}