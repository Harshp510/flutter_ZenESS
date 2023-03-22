import 'dart:convert';

class DepartmentsModel {
  String? departmentId;
  String? departmentName;

  DepartmentsModel({this.departmentId, this.departmentName});

  DepartmentsModel.fromJson(Map<String, dynamic> json) {
    departmentId = json['department_id'];
    departmentName = json['Department_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['department_id'] = this.departmentId;
    data['Department_Name'] = this.departmentName;
    return data;
  }

  List<DepartmentsModel> DepartmentsModelFromJson(String str) =>
      List<DepartmentsModel>.from(json.decode(str).map((x) => DepartmentsModel.fromJson(x)));

  String DepartmentsModelToJson(List<DepartmentsModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}