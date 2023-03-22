
import 'dart:convert';
import 'dart:io';

import 'package:Face_recognition/DashBoardPage.dart';
import 'package:Face_recognition/DialogBuilder.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ApiService.dart';
import 'model/EmailCheck_Model.dart';
import 'model/LoginDataModel.dart';

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {

  bool ispassowrd_visible = false;
  bool isemail_visible = true;
  bool isusername_visible = false;
  bool islogin_btn_changed = false;
  String str_user_email="";

  TextEditingController _controller_email = new TextEditingController();
  TextEditingController _controller_password = new TextEditingController();
  List<LoginDataModel> login_data_list=[];
  List<EmailCheck_Model> email_check_list=[];
  final textFieldFocusNode = FocusNode();
  bool _obscured = false;
  void _navigateToNextScreen(BuildContext nextcontext) {
    Navigator.push(nextcontext,MaterialPageRoute(builder: (nextcontext) => DashBoardPage()));
  }
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) return; // If focus is on text field, dont unfocus
      textFieldFocusNode.canRequestFocus = false;     // Prevents focus if tap on eye
    });
  }
  Future<void> _doLogin(BuildContext context1)  async {


    bool connection_flag= await ApiService().check_connection_network();
    print("connection_flag-->"+connection_flag.toString());

      if(connection_flag)
      {
        DialogBuilder(context1).showLoadingIndicator('');
        String username = _controller_email.text;
        var bytes = utf8.encode(_controller_password.text);
        var password = base64.encode(bytes);
        ApiService apiService = new ApiService();
        login_data_list = await apiService.Login(username, password);
        if (login_data_list.length > 0)
        {

          if(login_data_list[0].status=="1")
          {
            PreferenceUtils.setString("EmployeeId", login_data_list[0].employeeId.toString());
            PreferenceUtils.setString("Emp_Firstname", login_data_list[0].empFirstname.toString());
            PreferenceUtils.setString("Emp_Lastname", login_data_list[0].empLastname.toString());
            PreferenceUtils.setString("Emp_Designation", login_data_list[0].empDesignation.toString());
            PreferenceUtils.setString("Emp_Location", login_data_list[0].empLocation.toString());
            PreferenceUtils.setString("Emp_department", login_data_list[0].empDepartment.toString());
            PreferenceUtils.setString("username", username);
            PreferenceUtils.setString("password", password);

            DialogBuilder(context1).hideOpenDialog();
            _navigateToNextScreen(context1);
          }
          else
          {
            DialogBuilder(context1).hideOpenDialog();
            Future.delayed(Duration(seconds: 1),(){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(login_data_list[0].message.toString()),));
            });
          }



        } else {
          DialogBuilder(context1).hideOpenDialog();
          throw Exception("error");
        }
      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Internet not available"),));
      }





  }

  Future getLocationPermission() async {

 /*   DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    int? androidversion =  androidInfo.version.sdkInt;*/
    if(Platform.isAndroid || Platform.isIOS){
      PermissionStatus status2 = await Permission.location.request();
      if (status2.isGranted) {
        return true;
      } else if (status2.isPermanentlyDenied) {
        await openAppSettings();
      } else if (status2.isDenied) {
        print('Permission Denied');
      }
    }

    //PermissionStatus status1 = await Permission.accessMediaLocation.request();



  }
  Future<void> _doEmail_check(BuildContext context1) async
  {
    bool _permissionReady = await getLocationPermission();
    print('_permissionReady'+_permissionReady.toString());
    if(_permissionReady){
      bool connection_flag= await ApiService().check_connection_network();
      print("connection_flag-->"+connection_flag.toString());

      if(connection_flag)
      {
        DialogBuilder(context1).showLoadingIndicator('');
        String username = _controller_email.text;
        // var bytes = utf8.encode(_controller_password.text);
        // var password = base64.encode(bytes);
        ApiService apiService = new ApiService();
        email_check_list = await apiService.checkemail_validate(username);
        if (email_check_list.length > 0) {

          if (email_check_list[0].status == "1") {
            setState(() {
              isemail_visible = false;
              isusername_visible = true;
              ispassowrd_visible = true;
              islogin_btn_changed = true;
              str_user_email = _controller_email.text;
            });
            DialogBuilder(context1).hideOpenDialog();
          }
          else
          {
            DialogBuilder(context1).hideOpenDialog();
            Future.delayed(Duration(seconds: 1),(){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(email_check_list[0].message.toString()),));
            });

          }
        } else {
          DialogBuilder(context1).hideOpenDialog();
          throw Exception("error");

        }
      }
      else
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Internet not available"),));
      }

    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,


      body: Stack(
        children: [
          Positioned(child:  Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: Container(
                      width: 280,
                      height: 270,
                      /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                      child: Image.asset('assets/images/splash_png.png')),
                ),
              ),
              Center(
                  child: Padding(padding: EdgeInsets.only(top: 15,bottom: 15),
                  child: Text('User Login',style: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.w500),),
                ),
              ),
              if(isemail_visible)
                Padding(
                  //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),

                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      textAlign: TextAlign.left,
                      controller: _controller_email,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(

                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Enter email id'),

                    ),
                  ),
                ),

              if(isusername_visible)...[
                UsernameShowUI(context),
                PasswordShowUI(context),
              ],


              Container(
                margin: EdgeInsets.only(top: 15),
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    /* Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Register()));*/
                    if(islogin_btn_changed){
                      _doLogin(context);
                    }else{
                      //email_check
                      _doEmail_check(context);
                    }

                  },
                  child: Text(
                    !islogin_btn_changed ? 'Next': 'Login',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

            ],
          )
          ),
          Positioned(

            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(padding:EdgeInsets.all(10),child: Text('Version 1.0')),
            ),
          )
        ],
      ),
    );
  }


  Widget UsernameShowUI(BuildContext context){

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,

      direction: Axis.horizontal,
      children: [

        Container(

          height:38,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue.shade400,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(str_user_email,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16,color: Colors.black87),),
              IconButton(onPressed: (){

                setState(() {
                  isemail_visible=true;
                  isusername_visible=false;
                  ispassowrd_visible = false;
                  islogin_btn_changed = false;
                  str_user_email="";
                  _controller_email.text="";


                });
              }, icon: SvgPicture.asset('assets/images/ic_close.svg'),iconSize: 18, padding: EdgeInsets.only(left: 5),
                constraints: BoxConstraints(),)
            ],
          ),

        )

        /*     Text('patel@zengroup.co.in',style: TextStyle(fontSize: 16,color: Colors.black87),),
                          IconButton(onPressed: (){}, icon: SvgPicture.asset('assets/images/ic_close.svg'),iconSize: 18, padding: EdgeInsets.only(left: 5),
                            constraints: BoxConstraints(),)*/

      ],
    );
  }

  Widget PasswordShowUI(BuildContext context){
    return  Padding(
      padding: const EdgeInsets.only(
          left: 15.0, right: 15.0, top: 15, bottom: 0),
      //padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: _controller_password,
        keyboardType: TextInputType.visiblePassword,
        obscureText: _obscured,
        focusNode: textFieldFocusNode,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            labelText: 'Password',
            hintText: 'Enter secure password',
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: GestureDetector(
                onTap: _toggleObscured,
                child: Icon(
                  _obscured
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 24,color: Colors.black45,
                ),
              ),
            ),
        ),

      ),
    );
  }
}