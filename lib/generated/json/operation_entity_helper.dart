import 'package:flutter_boss_says/data/entity/operation_entity.dart';
import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';

operationEntityFromJson(OperationEntity data, Map<String, dynamic> json) {
	if (json['entity'] != null) {
		data.entity = BossInfoEntity().fromJson(json['entity']);
	}
	if (json['pictureLocation'] != null) {
		data.pictureLocation = json['pictureLocation'].toString();
	}
	return data;
}

Map<String, dynamic> operationEntityToJson(OperationEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['entity'] = entity.entity?.toJson();
	data['pictureLocation'] = entity.pictureLocation;
	return data;
}