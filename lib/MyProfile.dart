import 'dart:convert';

import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'ApiConstants.dart';
import 'NavDrawer.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar:AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(ApiConstants.statusbar_color), // <-- SEE HERE
          statusBarIconBrightness: Brightness.dark, //<-- For Android SEE HERE (dark icons)
          statusBarBrightness: Brightness.light, //<-- For iOS SEE HERE (dark icons)
        ),
        elevation: 1,
        title: Text('My Profile',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w400),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu,color: Colors.black87,), onPressed: () { _scaffoldKey.currentState?.openDrawer();  },
        ),
       /* actions: [

          Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [


                  GestureDetector(
                    onTap: (){},
                    child: CircleAvatar(
                      child:  Container(

                        decoration: BoxDecoration(shape: BoxShape.circle,image: DecorationImage(
                            fit: BoxFit.fill,
                            image:MemoryImage(Base64Decoder().convert((PreferenceUtils.getString('image'))))
                        )),

                      ),
                      //backgroundImage: AssetImage('assets/images/splash_png.png'),

                    ),
                  ),
                ],
              )
          ),

        ],*/

        backgroundColor: Colors.white,
      ),
      drawer: NavDrawer(context),
      body: BodyView(context),
    );
  }

  Widget BodyView(BuildContext context){

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Profile_Pic(context),
          SizedBox(height: 20),
          Text(PreferenceUtils.getString('Emp_Firstname')+' '+PreferenceUtils.getString('Emp_Lastname'),style: TextStyle(fontSize: 20,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
          SizedBox(height: 7),
          Text(PreferenceUtils.getString('Emp_department'),style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black45),),
          SizedBox(height: 20),
          ProfileMenu(
            text: "Profile Details",
            icon: "assets/images/profile_detail_person.svg",
            color: 0xffC8DAF8,

            press: () => {},
          ),
          ProfileMenu(
            text: "Digital ID",
            icon: "assets/images/digital_id.svg",
            color: 0xffEAE8DA,

            press: () {},
          ),
          ProfileMenu(
            text: "Reset Password",
            icon: "assets/images/reset_password.svg",
            color: 0xffCCCDE8,

            press: () {},
          ),
          ProfileMenu(
            text: "Logout",
            icon: "assets/images/logout.svg",
            color: 0xffFAD7D7,

            press: () {},
          ),
        ],
      ),
    );
  }

  Widget Profile_Pic(BuildContext context){
    return  SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
           child:  Container(

             decoration: BoxDecoration(shape: BoxShape.circle,image: DecorationImage(
                 fit: BoxFit.fill,
                 image:MemoryImage(Base64Decoder().convert((PreferenceUtils.getString('image'))))
             )),

           ),
          ),
          Visibility(
            visible: false,
            child: Positioned(
              right: -16,
              bottom: 0,
              child: SizedBox(
                height: 46,
                width: 46,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Colors.white),
                    ),
                    primary: Colors.white,
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () {},
                  child: SvgPicture.asset("assets/images/Camera Icon.svg"),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,  required this.color,
  }) : super(key: key);

  final String text, icon;
  final int color;

  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        leading:CircleAvatar(
          backgroundColor: Color(color),
          radius: 25,
          child:  SvgPicture.asset(
            icon,
            width: 24,

          ),
        ),
        onTap: press,
        title:  Text(text,style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
        trailing:  Icon(Icons.keyboard_arrow_right,),
        /* Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 22,
            ),
            SizedBox(width: 20),
            Expanded(child: Text(text)),
            Icon(Icons.arrow_forward_ios),
          ],
        ),*/
      ),
    );
  }
}
