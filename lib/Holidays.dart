import 'dart:convert';

import 'package:Face_recognition/ApiService.dart';
import 'package:Face_recognition/model/ShowLocationModel.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'ApiConstants.dart';
import 'MyProfile.dart';
import 'NavDrawer.dart';
import 'SlideRightRoute.dart';
import 'model/ShowLocationLeaveModel.dart';

class Holidays extends StatefulWidget {
  const Holidays({Key? key}) : super(key: key);

  @override
  State<Holidays> createState() => _HolidaysState();
}

class _HolidaysState extends State<Holidays> with TickerProviderStateMixin  {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _controller;
  int _selectedIndex = 0;
  List<ShowLocationModel> locationlist = [];
  List<Tab> _tabs = [];
  List<Widget> _generalWidgets = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationlist.clear();

  }

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
      body: DefaultTabView(context),
    );
  }
  
  Widget DefaultTabView(BuildContext context){
    
    return FutureBuilder<List<ShowLocationModel>>(
        future:ApiService().ShowLocation(),
        builder: (context,snapshot){
      if (snapshot.connectionState == ConnectionState.waiting) {
        return ProgressIndicator(context,"Please Wait..");
      }
      else if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return  Center(child: Text('Something Went Wrong'));
        } else if (snapshot.hasData) {
          locationlist = snapshot.data!;
          return DefaultTabController(length: locationlist.length, child: Column(
            children: [
              TabBar(
                indicatorColor: Color(ApiConstants.statusbar_color),
                isScrollable: true,
                labelColor: Color(ApiConstants.statusbar_color),
                unselectedLabelColor: Colors.black87,
                labelStyle: TextStyle(fontSize: 14.0,fontFamily: ApiConstants.fontname,letterSpacing: 1.5),  //For Selected tab
                unselectedLabelStyle: TextStyle(fontSize: 14,fontFamily:ApiConstants.fontname), //For Un-selected Tabs
                tabs:new List<Widget>.generate(locationlist.length, (index){
                  return Tab(text: locationlist[index].locationName.toString().toUpperCase());

                }),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children:new List<Widget>.generate(locationlist.length,(index){
                    return tabListWidget(locationlist[index].locationId.toString());
                  }),
                ),
              )
            ],
          )
          );
        } else {
          return  Center(child: Text('Empty data'));
        }
      } else {
        return  ProgressIndicator(context,"Please Wait..");
      }
    });
  }


  Widget tabListWidget(String location_id){
    return FutureBuilder<List<ShowLocationLeaveModel>>(
        future: ApiService().ShowLocation_Leave(location_id),
        builder: (context,snapshot){
      if (snapshot.connectionState == ConnectionState.waiting) {
        return ProgressIndicator(context,"Please Wait..");
      }
      else if(snapshot.connectionState==ConnectionState.done)
      {
        if(snapshot.hasError)
          {
            return  Center(child: Text('Something Went Wrong'));
          }
       else if(snapshot.hasData)
         {
           return ListView.builder(itemCount: snapshot.data!.length,itemBuilder: (context,index){

             return Container(
                 margin: EdgeInsets.only(top: 10,left: 15,right: 15),
                 width: double.infinity,
                 decoration: BoxDecoration(
                     border: Border.all(color:Color(0xffDADCE0),width: 0.5), borderRadius: BorderRadius.all(Radius.circular(8))
                 ),
                 child:Column(
                   children: [
                     ListTile(
                       leading: CircleAvatar(
                         backgroundColor: Color(0xffd9e4fc),
                         radius: 25,
                         child:  SvgPicture.asset(
                           "assets/images/ic_holiday.svg",
                           width: 24,

                         ),
                       ),
                       title: Text(snapshot.data![index].leaveName.toString()),
                       subtitle: Text(snapshot.data![index].leaveDate.toString()+"|"+snapshot.data![index].leaveDay.toString()) ,
                       onTap: (){

                       },
                     )
                   ],
                 )

             );
           });
         }
       else
         {
           return  Center(child: Text('Empty data'));
         }

      }
      else
        {
          return  ProgressIndicator(context,"Please Wait..");

        }
    });
  }
  Widget ProgressIndicator(BuildContext context,String title){
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 15,),
          Text(title,style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87),)
        ],
      ),
    );
  }
}
