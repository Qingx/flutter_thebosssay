import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';
import 'package:flutter_boss_says/util/base_empty.dart';

class TokenEntity with JsonConvert<TokenEntity> {
  String token;
  UserEntity userInfo = BaseEmpty.emptyUser;

  @override
  String toString() {
    return 'TokenEntity{token: $token, userInfo: $userInfo}';
  }
}
