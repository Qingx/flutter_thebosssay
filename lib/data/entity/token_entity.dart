import 'package:flutter_boss_says/data/entity/user_entity.dart';
import 'package:flutter_boss_says/generated/json/base/json_convert_content.dart';

class TokenEntity with JsonConvert<TokenEntity>{
  String token;
  UserEntity userInfo;

  @override
  String toString() {
    return 'TokenEntity{token: $token, userInfo: $userInfo}';
  }
}
