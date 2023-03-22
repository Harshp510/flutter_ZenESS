import 'dart:convert';

import 'package:Face_recognition/ApiService.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'ApiConstants.dart';
import 'MyProfile.dart';
import 'SlideRightRoute.dart';
import 'model/InsertEmployeeLogByEmpIDModel.dart';

class PuchVerify extends StatefulWidget {
  String emp_id;
  double? latitude;
  double? longitude;
   PuchVerify({Key? key,required this.emp_id,required this.latitude,required this.longitude}) : super(key: key);

  @override
  State<PuchVerify> createState() => _PuchVerifyState();
}

class _PuchVerifyState extends State<PuchVerify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime current_date;

  String GetDateTime()  {
    current_date = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(current_date);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar:AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(ApiConstants.statusbar_color), // <-- SEE HERE
          statusBarIconBrightness: Brightness.dark, //<-- For Android SEE HERE (dark icons)
          statusBarBrightness: Brightness.light, //<-- For iOS SEE HERE (dark icons)
        ),
        elevation: 1,
        title: Text('Time Keeping',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w400),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black87,), onPressed: () { Navigator.pop(context);  },
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
      ),
      body: FutureApicall(context),
    );
  }
  
  final ButtonStyle flatButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xff407AFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
  Widget FutureApicall(BuildContext context){
    
    return FutureBuilder<List<InsertEmployeeLogByEmpIDModel>>(

      future: ApiService().InsertEmployeeLogByEmpID(PreferenceUtils.getString("EmployeeId"), GetDateTime(), widget.latitude.toString(),widget.latitude.toString()),
      builder: (context,snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ProgressIndicator(context);
        }
        else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return  Center(child: Text('Something Went Wrong'));
          } else if (snapshot.hasData) {
            return BodyView(context,snapshot.data!);
          } else {
            return  Center(child: Text('Empty data'));
          }
        } else {
          return  ProgressIndicator(context);
        }
      },
    );
  }
  Widget BodyView(BuildContext context,List<InsertEmployeeLogByEmpIDModel> list){

    if(list[0].logStatus == "1"){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text(list[0].punchStatus.toString() == "Check_In" ? 'You have successfully Punched In at':'You have successfully Punched Out at' ,style: TextStyle(fontSize: 20,fontFamily: ApiConstants.fontname,color: Colors.black87,fontWeight: FontWeight.normal),),
          SizedBox(height: 15),

          Text(list[0].currTime.toString(),style: TextStyle(fontSize: 24,fontFamily: ApiConstants.fontname,color: Colors.black,fontWeight: FontWeight.bold),),
          SizedBox(height: 15),
          Container(
            margin: EdgeInsets.only(left: 25,right: 25),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(

                style: flatButtonStyle,
                onPressed: () async {
                  /* Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SecondScreen()));*/


                },
                child: Text('Verify Your Attendance Code',style: TextStyle(fontSize: 16,color: Colors.white,fontFamily: ApiConstants.fontname,fontWeight: FontWeight.normal),),
              ),
            ),
          )
        ],

      );
    }else{
      return Center(child: Text('Punch Error'));
    }

  }
  Widget ProgressIndicator(BuildContext context){
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 15,),
          Text('Please Wait..',style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87),)
        ],
      ),
    );
  }
}
