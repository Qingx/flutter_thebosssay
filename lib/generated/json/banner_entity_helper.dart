import 'package:flutter_boss_says/data/entity/banner_entity.dart';

bannerEntityFromJson(BannerEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'].toString();
	}
	if (json['pictureLocation'] != null) {
		data.pictureLocation = json['pictureLocation'].toString();
	}
	if (json['pictureType'] != null) {
		data.pictureType = json['pictureType'].toString();
	}
	if (json['resourceId'] != null) {
		data.resourceId = json['resourceId'].toString();
	}
	return data;
}

Map<String, dynamic> bannerEntityToJson(BannerEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['pictureLocation'] = entity.pictureLocation;
	data['pictureType'] = entity.pictureType;
	data['resourceId'] = entity.resourceId;
	return data;
}