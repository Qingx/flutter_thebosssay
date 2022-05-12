import 'package:flutter_boss_says/data/entity/boss_info_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class OperationEntity with JsonConvert<OperationEntity> {
  BossInfoEntity entity;
  String pictureLocation = "";

  @override
  String toString() {
    return 'OperationPhotoEntity{entity: $entity, pictureLocation: $pictureLocation}';
  }
}
