

import 'dart:convert';

import 'package:Face_recognition/ApiConstants.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/provider/DrawerItemRow.dart';
import 'package:Face_recognition/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'DialogBuilder.dart';
import 'Employee_Directory.dart';
import 'NavigationService.dart';
import 'SplashPage.dart';
import 'main.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer(BuildContext context);



  @override  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  String _currentRoute = "/";
  bool is_expand=false;


  void _navigateToMainpage1(BuildContext nextcontext)
  {
    Future.delayed(Duration(milliseconds: 400),()
    {
      final abc = NavigationService.navigatorKey.currentContext;
      //Navigator.pushNamed(abc!, "/second");
      print("ccc-->"+abc!.widget.toStringShort());
      doRoute(abc, "/");
      print("Material App Context :"+NavigationService.navigatorKey.currentContext.toString());


    });

  }
  void _navigateToMainpage2(BuildContext nextcontext)
  {
    Future.delayed(Duration(milliseconds: 400),()
    {
      final abc = NavigationService.navigatorKey.currentContext;
      //Navigator.pushNamed(abc!, "/second");

      doRoute(abc!, "/second");



    });

  }
  void _navigateToRegister(BuildContext nextcontext)
  {
    Future.delayed(Duration(milliseconds: 400),()
    {
      final abc = NavigationService.navigatorKey.currentContext;
      //Navigator.pushNamed(abc!, "/second");

      doRoute(abc!, "/register");



    });

  }
  void _navigateToHolidays(BuildContext nextcontext)
  {
    Future.delayed(Duration(milliseconds: 400),()
    {
      final abc = NavigationService.navigatorKey.currentContext;
      //Navigator.pushNamed(abc!, "/second");

      doRoute(abc!, "/holidays");



    });

  }
  void _navigateToAttendanceCode(BuildContext nextcontext)
  {
    Future.delayed(Duration(milliseconds: 400),()
    {
      final abc = NavigationService.navigatorKey.currentContext;
      //Navigator.pushNamed(abc!, "/second");

      doRoute(abc!, "/attendance_code");



    });

  }
  void doRoute(BuildContext context, String name) {
    _currentRoute = Provider.of<DrawerItemRow>(context,listen: false).currentRoute;
    print('route-->'+_currentRoute);
    if (_currentRoute != name)
      Navigator.pushNamed(context, name);
    /*else
      Navigator.pop(context);*/

    _currentRoute = name;
    Provider.of<DrawerItemRow>(context,listen: false).UpdateRoute(_currentRoute);
  }
  void _navigateToLogout(BuildContext nextcontext)
  {
    Navigator.pushReplacement(nextcontext,MaterialPageRoute(builder: (nextcontext) => SPlashPage()));
  }
  @override  Widget build(BuildContext context) {
   // print("data is ${data.length}

    return
       new Drawer(
         width: 280,
        child: new ListView(
          children: <Widget>[

            new UserAccountsDrawerHeader(
              accountName: new Text(PreferenceUtils.getString('Emp_Firstname')+' '+PreferenceUtils.getString('Emp_Lastname')),
              accountEmail: new Text(PreferenceUtils.getString('Emp_Designation')),
              decoration: new BoxDecoration(
                color: Color(ApiConstants.statusbar_color)
                /*image: new DecorationImage(
                  image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT5mkOaNp-d1TH_QzjDqTW2m0mKE1gh11QpF1L7vHqpaUS_8Ys3"),
                  fit: BoxFit.cover,
                ),*/
              ),
              currentAccountPicture: /*CircleAvatar(

                  child: ClipOval(child: Image.memory(Base64Decoder().convert((PreferenceUtils.getString('image')))))
              )*/
              Container(
                height: 80,
                width: 80,
                padding: EdgeInsets.all(8), // Border width
                decoration: BoxDecoration(shape: BoxShape.circle,image: DecorationImage(
                  fit: BoxFit.fill,
                  image:MemoryImage(Base64Decoder().convert((PreferenceUtils.getString('image'))))
                )),

                ),
              ),


            new ListTile(

                leading: SvgPicture.asset( "assets/images/ic_drawer_dashboard.svg",
                    width: 24),
                minLeadingWidth: 5,
                title: new Text("Dashboard",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                onTap: () {

                  _navigateToMainpage1(context);
                  Navigator.pop(context);


                }),

            Visibility(
              visible: true,
              child: new ListTile(
                 // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32))),
                  minLeadingWidth: 5,
                  leading:  SvgPicture.asset( "assets/images/ic_drawer_employee_directory.svg",
                      width: 24),
                  title: new Text("Employee Directory",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                  onTap: () {

                    _navigateToMainpage2(context);
                    Navigator.pop(context);

                  }),
            ),
            Visibility(
              visible: true,
              child: new ListTile(
                  minLeadingWidth: 5,
                  leading:  SvgPicture.asset( "assets/images/ic_drawer_time_keeping.svg",
                      width: 24),
                  title: new Text("Time Keeping",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                  onTap: () {
                    Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(false);
                    _navigateToRegister(context);
                    Navigator.pop(context);
                  }),
            ),
            new ListTile(
                minLeadingWidth: 5,
                leading: SvgPicture.asset( "assets/images/ic_drawer_attendance_code.svg",
                    width: 24),
                title: new Text("Attendance",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                onTap: () {
                  _navigateToAttendanceCode(context);
                  Navigator.pop(context);
                }),
            ExpansionTile(

              onExpansionChanged:(state){
                setState(() {
                  is_expand=state;
                });
              } ,
              leading:SvgPicture.asset( "assets/images/ic_drawer_hr_forms.svg",
                  width: 24),
              trailing: is_expand?Icon(Icons.arrow_drop_up):Icon(Icons.arrow_drop_down),
              title: Transform(
                  transform: Matrix4.translationValues(-16, 0.0, 0.0),
                  child: Text("HR Forms",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),)),
              children: <Widget>[
                ListTile(
                  onTap: (){},
                  title: Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Text("Leave Application", textAlign: TextAlign.left,style: TextStyle(fontSize: 15,fontFamily: ApiConstants.fontname,color: Color(ApiConstants.navi_expansion_child_text_color),fontWeight: FontWeight.normal),)),
                ),
                ListTile(
                  onTap: (){},
                  title: Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Text("Early Late Application",textAlign: TextAlign.left,style: TextStyle(fontSize: 15,fontFamily: ApiConstants.fontname,color: Color(ApiConstants.navi_expansion_child_text_color),fontWeight: FontWeight.normal),)),
                ),
                ListTile(
                  onTap: (){},
                  title: Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Text("Out On Office Duty",textAlign: TextAlign.left,style: TextStyle(fontSize: 15,fontFamily: ApiConstants.fontname,color: Color(ApiConstants.navi_expansion_child_text_color),fontWeight: FontWeight.normal),)),
                ),
                ListTile(
                  onTap: (){},
                  title: Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Text("Personal Timeout",textAlign: TextAlign.left,style: TextStyle(fontSize: 15,fontFamily: ApiConstants.fontname,color: Color(ApiConstants.navi_expansion_child_text_color),fontWeight: FontWeight.normal),)),
                ),
                ListTile(
                  onTap: (){},
                  title: Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Text("Work From Home",textAlign: TextAlign.left,style: TextStyle(fontSize: 15,fontFamily: ApiConstants.fontname,color: Color(ApiConstants.navi_expansion_child_text_color),fontWeight: FontWeight.normal),)),
                )
              ],
            ),
            new ListTile(
                minLeadingWidth: 5,
                leading: SvgPicture.asset( "assets/images/ic_drawer_earnings.svg",
                    width: 24),
                title: new Text("Earnings",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                onTap: () {
                  Navigator.pop(context);
                }),
            new ListTile(
                minLeadingWidth: 5,
                leading: SvgPicture.asset( "assets/images/ic_drawer_holidays.svg",
                    width: 24),
                title: new Text("Holidays",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                onTap: () {
                  _navigateToHolidays(context);
                  Navigator.pop(context);
                  // Navigator.pop(context);
                }),
            new ListTile(
                minLeadingWidth: 5,
                leading: Icon(Icons.power_settings_new,color: Color(0xff343434),),
                title: new Text("Logout",style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
                onTap: () {
                  Navigator.pop(context);
                  DialogBuilder(context).showLoadingIndicator('');
                  dbHelper.DbClear_All_Data();
                  Provider.of<DrawerItemRow>(context,listen: false).updateRegisterState(false);
                  Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(false);
                  PreferenceUtils.Clear_Preferences();


                  Future.delayed(Duration(seconds: 3),()
                  {
                    final abc = NavigationService.navigatorKey.currentContext;
                    DialogBuilder(abc!).hideOpenDialog();
                    _navigateToLogout(abc);
                  });


                }),
          ],
        ),

    );
  }
}

