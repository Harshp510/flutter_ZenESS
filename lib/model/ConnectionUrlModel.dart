import 'dart:convert';

class ConnectionUrlModel {
  String? status;
  String? message;

  ConnectionUrlModel({this.status, this.message});

  ConnectionUrlModel.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }

  List<ConnectionUrlModel> connurlcheckModelFromJson(String str) =>
      List<ConnectionUrlModel>.from(json.decode(str).map((x) => ConnectionUrlModel.fromJson(x)));

  String connurlcheckModelToJson(List<ConnectionUrlModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}