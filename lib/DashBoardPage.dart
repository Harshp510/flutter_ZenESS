import 'dart:convert';
import 'dart:typed_data';

import 'package:Face_recognition/ApiConstants.dart';
import 'package:Face_recognition/MyProfile.dart';
import 'package:Face_recognition/model/PhotoModel.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/provider/DrawerItemRow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ApiService.dart';
import 'NavDrawer.dart';
import 'NavigationService.dart';
import 'SlideRightRoute.dart';
import 'main.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  List<PhotoModel> photolist = [];
 // late Uint8List encodeedimg;


  void _getPhoto(String empid) async {

    ApiService apiService = new ApiService();
    photolist = await apiService.GetEmployeePhotoByEmpID(empid);
    if (photolist.length > 0) {
      var img64 = photolist[0].photo.toString();


      PreferenceUtils.setString("image", img64);
    } else {

      PreferenceUtils.setString("image", '');

    }
  }
  Future<int> getCount() async {
    //database connection
    /*  var databasesPath = await getDatabasesPath();
    print("db_path1==>"+databasesPath.toString());
    var path = join(databasesPath, "face_rec_ess.db");
    var bomDataTable = await openDatabase(path, readOnly: true);
    final results = await bomDataTable.rawQuery('SELECT COUNT(*) FROM face_rec_ess_table');
    return Sqflite.firstIntValue(results) ?? 0;*/
    int count = await dbHelper.queryRowCount();
    print('cnt-->'+count.toString());
    return count;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      dbHelper.getEmployeeName(PreferenceUtils.getString("EmployeeId")).then((value) => {
        debugPrint('dbname->'+value)
      });
    if(PreferenceUtils.getString('image').length==0){
      _getPhoto(PreferenceUtils.getString("EmployeeId"));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // your method where use the context
      // Example navigate:
      final abc = NavigationService.navigatorKey.currentContext;
      //  locationStatus(abc).then((value) => {})
      getCount().then((value) => {
        print(value),
        if (value == 0)
          {
            debugPrint(value.toString()),
            Provider.of<DrawerItemRow>(abc!,listen: false).updateRegisterState(false)

          }
        else
          {
            debugPrint(value.toString()),
            Provider.of<DrawerItemRow>(abc!,listen: false).updateRegisterState(true)

          }
      });
    });
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
        title: Text('ESS',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w400),),
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
      ),
      drawer: NavDrawer(context),
    );
  }
}
