import 'dart:convert';

class PhotoModel {
  String? photo;

  PhotoModel({this.photo});

  PhotoModel.fromJson(Map<String, dynamic> json) {
    photo = json['Photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Photo'] = this.photo;
    return data;
  }

  List<PhotoModel> PhotoModelFromJson(String str) =>
      List<PhotoModel>.from(json.decode(str).map((x) => PhotoModel.fromJson(x)));

  String PhotoModelToJson(List<PhotoModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
