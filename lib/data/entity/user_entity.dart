import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class UserEntity with JsonConvert<UserEntity> {
  String avatar; //头像
  String deviceId; //设备号
  String id; //id
  String nickName; //账号
  String phone; //手机号
  int collectNum; //收藏数
  int readNum; //今日阅读数
  int traceNum; //追踪数量
  String type;
  String wxHead;
  String wxName;

  bool isNotEmpty() => id != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserEntity{avatar: $avatar, collectNum: $collectNum, deviceId: $deviceId, id: $id, nickName: $nickName, phone: $phone, readNum: $readNum, traceNum: $traceNum, type: $type, wxHead: $wxHead, wxName: $wxName}';
  }
}
