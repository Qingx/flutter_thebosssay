class UserModel {
  int id;
  String mobile;
  String headImage;

  static UserModel fromJson(Map<String, dynamic> map) {
    return UserModel()
      ..id = map["id"]
      ..mobile = map["mobile"]
      ..headImage = map["headImage"];
  }

  @override
  String toString() {
    return 'UserModel{id: $id, mobile: $mobile, headImage: $headImage}';
  }
}
