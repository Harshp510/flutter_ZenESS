

import 'dart:convert';

class ERPAccessModel {
  String? accessTo;
  String? accessValue;
  String? status;
  String? uUID;

  ERPAccessModel({this.accessTo, this.accessValue, this.status, this.uUID});

  ERPAccessModel.fromJson(Map<String, dynamic> json) {
    accessTo = json['Access_To'];
    accessValue = json['Access_Value'];
    status = json['Status'];
    uUID = json['UUID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Access_To'] = this.accessTo;
    data['Access_Value'] = this.accessValue;
    data['Status'] = this.status;
    data['UUID'] = this.uUID;
    return data;
  }

  List<ERPAccessModel> ERPAccessModelFromJson(String str) =>
      List<ERPAccessModel>.from(json.decode(str).map((x) => ERPAccessModel.fromJson(x)));

  String ERPAccessModelToJson(List<ERPAccessModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}