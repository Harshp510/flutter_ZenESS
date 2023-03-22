import 'dart:convert';

class UserFaceDb_Model {
  String? uRL;

  UserFaceDb_Model({this.uRL});

  UserFaceDb_Model.fromJson(Map<String, dynamic> json) {
    uRL = json['URL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['URL'] = this.uRL;
    return data;
  }

  List<UserFaceDb_Model> userModelFromJson(String str) =>
      List<UserFaceDb_Model>.from(json.decode(str).map((x) => UserFaceDb_Model.fromJson(x)));

  String userModelToJson(List<UserFaceDb_Model> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}