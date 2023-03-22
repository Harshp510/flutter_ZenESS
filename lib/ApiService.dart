

import 'dart:convert';
import 'dart:developer';

import 'package:Face_recognition/ApiConstants.dart';
import 'package:Face_recognition/model/ConnectionUrlModel.dart';
import 'package:Face_recognition/model/DepartmentsModel.dart';
import 'package:Face_recognition/model/EmailCheck_Model.dart';
import 'package:Face_recognition/model/EmployeeModel.dart';
import 'package:Face_recognition/model/InsertEmployeeLogByEmpIDModel.dart';
import 'package:Face_recognition/model/LoginDataModel.dart';
import 'package:Face_recognition/model/PhotoModel.dart';
import 'package:Face_recognition/model/ShowLocationLeaveModel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'model/ERPAccessModel.dart';
import 'model/ShowLocationModel.dart';
import 'model/UserFaceDb_Model.dart';
import 'package:http/http.dart' as http;

class ApiService{


  Future<List<UserFaceDb_Model>?> getFacefb_file(String Connectionname,String emp_id) async{

    try{
     // Download_FilesPortalApplicationUserData?Connectionname=zepl.zenhrp.in&EmpId=0a130486-3e0d-422a-a0c7-e5712385dca8
      var url = ApiConstants.baseUrl + "Download_FilesPortalApplicationUserData?Connectionname="+Connectionname+"&EmpId="+emp_id;
      print('URL==>'+url);

     var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
         onTimeout: () {
           // Time has run out, do what you wanted to do.
           return http.Response('Error', 408); // Request Timeout response status code
         });
     print(res.body);
     if(res.statusCode == 200){
       List<UserFaceDb_Model> list = UserFaceDb_Model().userModelFromJson(res.body);

       return list;
     }

    }catch (e){

      log(e.toString());
    }
  }

  Future<List<EmailCheck_Model>> checkemail_validate(String emailid) async
  {
    List<EmailCheck_Model> list = [];
    try {
      var url = ApiConstants.baseUrl + "GetEmailIDCheck?EmailID=" + emailid +
          "";
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = EmailCheck_Model().emailcheckModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    return list;
  }
  Future<List<LoginDataModel>> Login(String emailid,String password) async
  {
    List<LoginDataModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "GetCheckCredentials?EmailId="+emailid+"&Password="+password+"";
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = LoginDataModel().LoginDataModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }

  Future<List<ConnectionUrlModel>> check_conn_url(String checkurl) async
  {
    List<ConnectionUrlModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "CurrentUrlStatus?Url=" + checkurl + "";

      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response('Error', 408); // Request Timeout response status code
        });
      print("res" + res.body);

      if (res.statusCode == 200)
      {
        list = ConnectionUrlModel().connurlcheckModelFromJson(res.body);
      }else{
        print(res.statusCode);
      }
    } catch (e) {
      log(e.toString());
    }
    return list;
  }

  Future<bool> check_connection_network() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<List<DepartmentsModel>> getDepartment() async
  {
    List<DepartmentsModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "ShowDepartments";
      print('URL==>' + url);

      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = DepartmentsModel().DepartmentsModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }
  Future<List<EmployeeModel>> getEmployeeDirectory(String emp_id) async
  {
    List<EmployeeModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "ShowEmployeeDirectory?EmpId="+emp_id;
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = EmployeeModel().EmployeeModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }

  Future<List<ERPAccessModel>> getERPAcess(String emp_id) async
  {
    List<ERPAccessModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "Emp_HRPAccess?EmpID="+emp_id;
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = ERPAccessModel().ERPAccessModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }
  Future<List<PhotoModel>> GetEmployeePhotoByEmpID(String emp_id) async
  {
    List<PhotoModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "GetEmployeePhotoByEmpID?EmployeeID="+emp_id;
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = PhotoModel().PhotoModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }
  Future<List<InsertEmployeeLogByEmpIDModel>> InsertEmployeeLogByEmpID(String emp_id,String time,String latitude,String longitude) async
  {
    List<InsertEmployeeLogByEmpIDModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "InsertEmployeeLogByEmpID?EmployeeID="+emp_id+"&datetime="+time+"&Flag=&EarlyLate=&Remarks=&Latitude="+latitude+"&Longitude="+longitude+"&macipadd=";
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = InsertEmployeeLogByEmpIDModel().InsertEmployeeLogByEmpIDModelModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }
  Future<List<ShowLocationModel>> ShowLocation() async
  {
    List<ShowLocationModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "ShowLocations";
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = ShowLocationModel().ShowLocationModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }


  Future<List<ShowLocationLeaveModel>> ShowLocation_Leave(String location_id) async
  {
    List<ShowLocationLeaveModel> list = [];
    try {
      var url = ApiConstants.baseUrl + "Show_LocationLeave?locationid="+location_id;
      print('URL==>' + url);
      var res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 408); // Request Timeout response status code
          });
      print("res" + res.body);

      if (res.statusCode == 200) {
        list = ShowLocationLeaveModel().ShowLocationLeaveModelFromJson(res.body);
      }
    } catch (e) {
      log(e.toString());
    }
    print('size-->'+list.length.toString());
    return list;
  }
}