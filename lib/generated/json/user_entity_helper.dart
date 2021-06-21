import 'package:flutter_boss_says/data/entity/user_entity.dart';

userEntityFromJson(UserEntity data, Map<String, dynamic> json) {
	if (json['avatar'] != null) {
		data.avatar = json['avatar'].toString();
	}
	if (json['balance'] != null) {
		data.balance = json['balance'] is String
				? int.tryParse(json['balance'])
				: json['balance'].toInt();
	}
	if (json['birthday'] != null) {
		data.birthday = json['birthday'] is String
				? int.tryParse(json['birthday'])
				: json['birthday'].toInt();
	}
	if (json['city'] != null) {
		data.city = json['city'].toString();
	}
	if (json['createTime'] != null) {
		data.createTime = json['createTime'] is String
				? int.tryParse(json['createTime'])
				: json['createTime'].toInt();
	}
	if (json['gender'] != null) {
		data.gender = json['gender'].toString();
	}
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['nickname'] != null) {
		data.nickname = json['nickname'].toString();
	}
	if (json['recentlySpent'] != null) {
		data.recentlySpent = json['recentlySpent'] is String
				? int.tryParse(json['recentlySpent'])
				: json['recentlySpent'].toInt();
	}
	if (json['telephone'] != null) {
		data.telephone = json['telephone'].toString();
	}
	if (json['token'] != null) {
		data.token = json['token'].toString();
	}
	if (json['wechatName'] != null) {
		data.wechatName = json['wechatName'].toString();
	}
	return data;
}

Map<String, dynamic> userEntityToJson(UserEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['avatar'] = entity.avatar;
	data['balance'] = entity.balance;
	data['birthday'] = entity.birthday;
	data['city'] = entity.city;
	data['createTime'] = entity.createTime;
	data['gender'] = entity.gender;
	data['id'] = entity.id;
	data['nickname'] = entity.nickname;
	data['recentlySpent'] = entity.recentlySpent;
	data['telephone'] = entity.telephone;
	data['token'] = entity.token;
	data['wechatName'] = entity.wechatName;
	return data;
}