import 'dart:convert';

class InsertEmployeeLogByEmpIDModel {
  String? logStatus;
  String? earlyLateStatus;
  String? timediff;
  String? timeFlag;
  String? currTime;
  String? punchStatus;
  String? currDate;
  String? notificationTitle;
  String? notificationText;

  InsertEmployeeLogByEmpIDModel(
      {this.logStatus,
        this.earlyLateStatus,
        this.timediff,
        this.timeFlag,
        this.currTime,
        this.punchStatus,
        this.currDate,
        this.notificationTitle,
        this.notificationText});

  InsertEmployeeLogByEmpIDModel.fromJson(Map<String, dynamic> json) {
    logStatus = json['LogStatus'];
    earlyLateStatus = json['EarlyLateStatus'];
    timediff = json['timediff'];
    timeFlag = json['TimeFlag'];
    currTime = json['CurrTime'];
    punchStatus = json['PunchStatus'];
    currDate = json['CurrDate'];
    notificationTitle = json['NotificationTitle'];
    notificationText = json['NotificationText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LogStatus'] = this.logStatus;
    data['EarlyLateStatus'] = this.earlyLateStatus;
    data['timediff'] = this.timediff;
    data['TimeFlag'] = this.timeFlag;
    data['CurrTime'] = this.currTime;
    data['PunchStatus'] = this.punchStatus;
    data['CurrDate'] = this.currDate;
    data['NotificationTitle'] = this.notificationTitle;
    data['NotificationText'] = this.notificationText;
    return data;
  }

  List<InsertEmployeeLogByEmpIDModel> InsertEmployeeLogByEmpIDModelModelFromJson(String str) =>
      List<InsertEmployeeLogByEmpIDModel>.from(json.decode(str).map((x) => InsertEmployeeLogByEmpIDModel.fromJson(x)));

  String InsertEmployeeLogByEmpIDModelModelToJson(List<InsertEmployeeLogByEmpIDModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}