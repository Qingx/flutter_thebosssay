import 'package:flutter_boss_says/data/entity/token_entity.dart';
import 'package:flutter_boss_says/data/entity/user_entity.dart';

tokenEntityFromJson(TokenEntity data, Map<String, dynamic> json) {
	if (json['token'] != null) {
		data.token = json['token'].toString();
	}
	if (json['userInfo'] != null) {
		data.userInfo = UserEntity().fromJson(json['userInfo']);
	}
	return data;
}

Map<String, dynamic> tokenEntityToJson(TokenEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['token'] = entity.token;
	data['userInfo'] = entity.userInfo?.toJson();
	return data;
}