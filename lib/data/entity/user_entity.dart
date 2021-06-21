import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class UserEntity with JsonConvert<UserEntity> {
  String avatar;
  int balance;
  int birthday;
  String city;
  int createTime;
  String gender;
  String id;
  String nickname;
  int recentlySpent;
  String telephone;
  String token;
  String wechatName;

  bool isNotEmpty() => id != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserEntity{avatar: $avatar, balance: $balance, birthday: $birthday, city: $city, createTime: $createTime, gender: $gender, id: $id, nickname: $nickname, recentlySpent: $recentlySpent, telephone: $telephone, token: $token, wechatName: $wechatName}';
  }
}
