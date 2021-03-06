import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class BannerEntity with JsonConvert<BannerEntity> {
  String id;
  String pictureLocation;
  String content;
  String pictureType;
  String resourceId;

  @override
  String toString() {
    return 'BannerEntity{id: $id, pictureLocation: $pictureLocation, content: $content, pictureType: $pictureType, resourceId: $resourceId}';
  }
}
