import 'dart:convert';
class LoginDataModel {
    String? status;
    String? message;
    String? employeeId;
    String? empFirstname;
    String? empLastname;
    String? empDesignation;
    String? empLocation;
    String? empDepartment;
    String? empContactNo;
    String? empGender;
    String? familyCount;

    LoginDataModel(
        {this.status,
            this.message,
            this.employeeId,
            this.empFirstname,
            this.empLastname,
            this.empDesignation,
            this.empLocation,
            this.empDepartment,
            this.empContactNo,
            this.empGender,
            this.familyCount});

    LoginDataModel.fromJson(Map<String, dynamic> json) {
        status = json['Status'];
        message = json['Message'];
        employeeId = json['EmployeeId'];
        empFirstname = json['Emp_Firstname'];
        empLastname = json['Emp_Lastname'];
        empDesignation = json['Emp_Designation'];
        empLocation = json['Emp_Location'];
        empDepartment = json['Emp_department'];
        empContactNo = json['Emp_ContactNo'];
        empGender = json['Emp_Gender'];
        familyCount = json['Family_count'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['Status'] = this.status;
        data['Message'] = this.message;
        data['EmployeeId'] = this.employeeId;
        data['Emp_Firstname'] = this.empFirstname;
        data['Emp_Lastname'] = this.empLastname;
        data['Emp_Designation'] = this.empDesignation;
        data['Emp_Location'] = this.empLocation;
        data['Emp_department'] = this.empDepartment;
        data['Emp_ContactNo'] = this.empContactNo;
        data['Emp_Gender'] = this.empGender;
        data['Family_count'] = this.familyCount;
        return data;
    }
    List<LoginDataModel> LoginDataModelFromJson(String str) =>
        List<LoginDataModel>.from(json.decode(str).map((x) => LoginDataModel.fromJson(x)));

    String LoginDataModelToJson(List<LoginDataModel> data) =>
        json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

