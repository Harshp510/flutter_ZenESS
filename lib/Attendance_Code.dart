
import 'dart:convert';

import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ApiConstants.dart';
import 'MyProfile.dart';
import 'NavDrawer.dart';
import 'SlideRightRoute.dart';

class Attendance_Code extends StatefulWidget {
  const Attendance_Code({Key? key}) : super(key: key);

  @override
  State<Attendance_Code> createState() => _Attendance_CodeState();
}

class _Attendance_CodeState extends State<Attendance_Code> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(ApiConstants.statusbar_color), // <-- SEE HERE
          statusBarIconBrightness: Brightness.dark, //<-- For Android SEE HERE (dark icons)
          statusBarBrightness: Brightness.light, //<-- For iOS SEE HERE (dark icons)
        ),
        elevation: 1,
        title: Text('Holidays',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w400,),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu,color: Colors.black87,), onPressed: () { _scaffoldKey.currentState?.openDrawer();  },
        ),
        actions: [

          Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [


                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, SlideRightRoute(page: MyProfile()));
                    },
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

        ],

        backgroundColor: Colors.white,
        /* bottom: TabBar(
            indicatorColor: Color(ApiConstants.statusbar_color),
            isScrollable: true,
            labelColor: Color(ApiConstants.statusbar_color),
            unselectedLabelColor: Colors.black87,
            controller: _controller,
            tabs:_tabs,
          )*/
      ),
      drawer: NavDrawer(context),
      body: DefaultTabview(context),
    );
  }

  Widget DefaultTabview(BuildContext context){
    return DefaultTabController(length: 2, child: Column(
      children: [
        TabBar(
          indicatorColor: Color(ApiConstants.statusbar_color),

          labelColor: Color(ApiConstants.statusbar_color),
          unselectedLabelColor: Colors.black87,
          labelStyle: TextStyle(fontSize: 14.0,fontFamily: ApiConstants.fontname,letterSpacing: 1.5),  //For Selected tab
          unselectedLabelStyle: TextStyle(fontSize: 14,fontFamily:ApiConstants.fontname), //For Un-selected Tabs
          tabs:[
               Tab(text: "Attendance".toUpperCase()),
               Tab(text: "Summary".toUpperCase())
          ]
        ),
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children:[
              Icon(Icons.flight, size: 350),
              Icon(Icons.directions_transit, size: 350),
            ]
          ),
        )
      ],
    )
    );
  }
}
