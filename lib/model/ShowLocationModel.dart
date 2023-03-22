import 'dart:convert';

class ShowLocationModel {
  String? locationId;
  String? locationName;

  ShowLocationModel({this.locationId, this.locationName});

  ShowLocationModel.fromJson(Map<String, dynamic> json) {
    locationId = json['LocationId'];
    locationName = json['LocationName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LocationId'] = this.locationId;
    data['LocationName'] = this.locationName;
    return data;
  }

  List<ShowLocationModel> ShowLocationModelFromJson(String str) =>
      List<ShowLocationModel>.from(json.decode(str).map((x) => ShowLocationModel.fromJson(x)));

  String ShowLocationModelToJson(List<ShowLocationModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}