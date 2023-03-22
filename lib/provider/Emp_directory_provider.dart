
import 'package:Face_recognition/ApiService.dart';
import 'package:Face_recognition/model/DepartmentsModel.dart';
import 'package:Face_recognition/model/EmployeeModel.dart';
import 'package:flutter/foundation.dart';

class Emp_directory_provider extends ChangeNotifier{

  List<DepartmentsModel> _departmentlist=[];
  List<EmployeeModel> _emp_list=[];
  List<EmployeeModel> _filter_emp_list=[];

  DepartmentsModel? _selected_department;
  List<DepartmentsModel> get departmentlist => _departmentlist;
  List<EmployeeModel> get emp_list => _emp_list;
  List<EmployeeModel> get filter_emp_list => _filter_emp_list;

  bool _isdialogshow=false;
  bool get isdialogshow => _isdialogshow;

  DepartmentsModel? get selectedDepartment => _selected_department;

   SetselectedDepartment(DepartmentsModel fruit) {
    _selected_department = fruit;
    notifyListeners();
  }

  Future<List<DepartmentsModel>> getDepartment() async{
    _isdialogshow = true;
     notifyListeners();
     _departmentlist = await ApiService().getDepartment();
     notifyListeners();
     return _departmentlist;
  }
  Future<List<EmployeeModel>> getEmp_list(String emp_id) async{
    _isdialogshow = false;
    _emp_list = await ApiService().getEmployeeDirectory(emp_id);
    notifyListeners();
    return _emp_list;
  }
  UpdateEmp_list(value){
    _filter_emp_list = value;
    notifyListeners();
  }

}