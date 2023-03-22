import 'dart:convert';

class EmployeeModel {
  String? departmentName;
  String? empName;
  String? email;
  String? contact1;
  String? locationName;
  String? designation;
  String? didno;
  String? empId;

  EmployeeModel(
      {this.departmentName,
        this.empName,
        this.email,
        this.contact1,
        this.locationName,
        this.designation,
        this.didno,
        this.empId});

  EmployeeModel.fromJson(Map<String, dynamic> json) {
    departmentName = json['Department_Name'];
    empName = json['Emp_name'];
    email = json['Email'];
    contact1 = json['Contact1'];
    locationName = json['LocationName'];
    designation = json['Designation'];
    didno = json['didno'];
    empId = json['Emp_Id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Department_Name'] = this.departmentName;
    data['Emp_name'] = this.empName;
    data['Email'] = this.email;
    data['Contact1'] = this.contact1;
    data['LocationName'] = this.locationName;
    data['Designation'] = this.designation;
    data['didno'] = this.didno;
    data['Emp_Id'] = this.empId;
    return data;
  }

  List<EmployeeModel> EmployeeModelFromJson(String str) =>
      List<EmployeeModel>.from(json.decode(str).map((x) => EmployeeModel.fromJson(x)));

  String EmployeeModelToJson(List<EmployeeModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}