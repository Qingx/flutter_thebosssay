import 'package:flutter_boss_says/data/entity/user_entity.dart';

userEntityFromJson(UserEntity data, Map<String, dynamic> json) {
	if (json['avatar'] != null) {
		data.avatar = json['avatar'].toString();
	}
	if (json['deviceId'] != null) {
		data.deviceId = json['deviceId'].toString();
	}
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['nickName'] != null) {
		data.nickName = json['nickName'].toString();
	}
	if (json['phone'] != null) {
		data.phone = json['phone'].toString();
	}
	if (json['collectNum'] != null) {
		data.collectNum = json['collectNum'] is String
				? int.tryParse(json['collectNum'])
				: json['collectNum'].toInt();
	}
	if (json['readNum'] != null) {
		data.readNum = json['readNum'] is String
				? int.tryParse(json['readNum'])
				: json['readNum'].toInt();
	}
	if (json['traceNum'] != null) {
		data.traceNum = json['traceNum'] is String
				? int.tryParse(json['traceNum'])
				: json['traceNum'].toInt();
	}
	if (json['pointNum'] != null) {
		data.pointNum = json['pointNum'] is String
				? int.tryParse(json['pointNum'])
				: json['pointNum'].toInt();
	}
	if (json['type'] != null) {
		data.type = json['type'].toString();
	}
	if (json['wxHead'] != null) {
		data.wxHead = json['wxHead'].toString();
	}
	if (json['wxName'] != null) {
		data.wxName = json['wxName'].toString();
	}
	if (json['tags'] != null) {
		data.tags = (json['tags'] as List).map((v) => v.toString()).toList().cast<String>();
	}
	return data;
}

Map<String, dynamic> userEntityToJson(UserEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['avatar'] = entity.avatar;
	data['deviceId'] = entity.deviceId;
	data['id'] = entity.id;
	data['nickName'] = entity.nickName;
	data['phone'] = entity.phone;
	data['collectNum'] = entity.collectNum;
	data['readNum'] = entity.readNum;
	data['traceNum'] = entity.traceNum;
	data['pointNum'] = entity.pointNum;
	data['type'] = entity.type;
	data['wxHead'] = entity.wxHead;
	data['wxName'] = entity.wxName;
	data['tags'] = entity.tags;
	return data;
}