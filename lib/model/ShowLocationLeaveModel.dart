import 'dart:convert';

class ShowLocationLeaveModel {
  String? leaveDate;
  String? leaveName;
  String? leaveDay;

  ShowLocationLeaveModel({this.leaveDate, this.leaveName, this.leaveDay});

  ShowLocationLeaveModel.fromJson(Map<String, dynamic> json) {
    leaveDate = json['LeaveDate'];
    leaveName = json['LeaveName'];
    leaveDay = json['LeaveDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LeaveDate'] = this.leaveDate;
    data['LeaveName'] = this.leaveName;
    data['LeaveDay'] = this.leaveDay;
    return data;
  }

  List<ShowLocationLeaveModel> ShowLocationLeaveModelFromJson(String str) =>
      List<ShowLocationLeaveModel>.from(json.decode(str).map((x) => ShowLocationLeaveModel.fromJson(x)));

  String ShowLocationLeaveModelToJson(List<ShowLocationLeaveModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}