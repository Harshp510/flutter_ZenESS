import 'package:Face_recognition/ConnectionCodePage.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'ApiService.dart';
import 'DashBoardPage.dart';
import 'LoginDemo.dart';
import 'NavigationService.dart';
import 'model/LoginDataModel.dart';

class SPlashPage extends StatefulWidget {
  const SPlashPage({Key? key}) : super(key: key);

  @override
  State<SPlashPage> createState() => _SPlashPageState();
}

class _SPlashPageState extends State<SPlashPage> {

  List<LoginDataModel> login_data_list=[];
 // bool isloggin = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _doUrl_check(context);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Splash_data(context),
    );
  }
  Widget Splash_data(BuildContext context)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 287,
            height: 270,
            padding: EdgeInsets.only(top: 40),
            child: Image.asset('assets/images/splash_png.png'),
          ),
        ),

        CircularProgressIndicator()
      ],
    );
  }


  void _doUrl_check(BuildContext context) async
  {
        String username="";
        String password="";
        username=PreferenceUtils.getString("username");
        password=PreferenceUtils.getString("password");
        print("username-->"+username);
        print("password-->"+password);





        if(username.length>0 || password.length>0)
        {
          bool connection_flag= await ApiService().check_connection_network();
          print("connection_flag-->"+connection_flag.toString());
          if(connection_flag)
          {
            _doLogin(context,username,password);
          }
          else
          {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Internet not available"),));

            Future.delayed(Duration(seconds: 5),()
            {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (nextcontext) => ConnectionCodePage()));
            });
          }

        }
        else
        {
          _navigateToLogin(context);
        }


  }

  void _doLogin(BuildContext context1,String username,String password) async {

    ApiService apiService = new ApiService();
    login_data_list = await apiService.Login(username, password);
    if (login_data_list.length > 0) {

      PreferenceUtils.setString("EmployeeId", login_data_list[0].employeeId.toString());
      PreferenceUtils.setString("Emp_Firstname", login_data_list[0].empFirstname.toString());
      PreferenceUtils.setString("Emp_Lastname", login_data_list[0].empLastname.toString());
      PreferenceUtils.setString("Emp_Designation", login_data_list[0].empDesignation.toString());
      PreferenceUtils.setString("Emp_Location", login_data_list[0].empLocation.toString());
      PreferenceUtils.setString("Emp_department", login_data_list[0].empDepartment.toString());
      PreferenceUtils.setString("username", username);
      PreferenceUtils.setString("password", password);

      _navigateToMainpage(context1);
    } else {

      _navigateToLogin(context1);

    }
  }


  void _navigateToLogin(BuildContext nextcontext)
  {
    Future.delayed(Duration(seconds: 3),()
    {
      Navigator.pushReplacement(nextcontext,MaterialPageRoute(builder: (nextcontext) => ConnectionCodePage()));
    });

  }
  void _navigateToMainpage(BuildContext nextcontext) {
    Future.delayed(Duration(seconds: 3),(){
      Navigator.pushReplacement(nextcontext,MaterialPageRoute(builder: (nextcontext) => DashBoardPage()));
    });

  }

}
