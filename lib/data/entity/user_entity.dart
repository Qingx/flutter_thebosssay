import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class UserEntity with JsonConvert<UserEntity> {
  String avatar; //头像
  String deviceId; //设备号
  String id; //id
  String nickName; //账号
  String phone; //手机号
  int collectNum = 0; //收藏数
  int readNum = 0; //今日阅读数
  int traceNum = 0; //追踪数量
  int pointNum = 0; //点赞数量
  String type; //0->游客 1->正式
  String wxHead;
  String wxName; //微信昵称
  List<String> tags = [];
  String version = "1000";

  bool isNotEmpty() => id != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserEntity{avatar: $avatar, deviceId: $deviceId, id: $id, nickName: $nickName, phone: $phone, collectNum: $collectNum, readNum: $readNum, traceNum: $traceNum, pointNum: $pointNum, type: $type, wxHead: $wxHead, wxName: $wxName, tags: $tags, version: $version}';
  }
}
