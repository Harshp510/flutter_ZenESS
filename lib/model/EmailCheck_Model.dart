import 'dart:convert';

class EmailCheck_Model {
  String? status;
  String? message;

  EmailCheck_Model({this.status, this.message});

  EmailCheck_Model.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }

  List<EmailCheck_Model> emailcheckModelFromJson(String str) =>
      List<EmailCheck_Model>.from(json.decode(str).map((x) => EmailCheck_Model.fromJson(x)));

  String emailcheckModelToJson(List<EmailCheck_Model> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}