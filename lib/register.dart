
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Face_recognition/ApiService.dart';
import 'package:Face_recognition/DatabaseHelper.dart';
import 'package:Face_recognition/DialogBuilder.dart';
import 'package:Face_recognition/LocationService.dart';
import 'package:Face_recognition/SplashPage.dart';
import 'package:Face_recognition/model/ERPAccessModel.dart';
import 'package:Face_recognition/model/UserFaceDb_Model.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/provider/DrawerItemRow.dart';
import 'package:Face_recognition/user.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:location/location.dart' as location;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'ApiConstants.dart';
import 'Homepage.dart';
import 'MyProfile.dart';
import 'NavDrawer.dart';
import 'NavigationService.dart';
import 'SlideRightRoute.dart';
import 'main.dart';



class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

 // var dbHelper  = new DatabaseHelper(); // CALLS FUTURE
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<RangingResult>? _streamRanging;
  late String data;
  List<User> listuser = [];
  File? jsonFile;
  Directory? tempDir;
  bool _permissionReady=false;
  bool _isregister=false;
  bool _isurldbfile=false;
  bool locationServiceEnabled = false;
  late List<UserFaceDb_Model>? _userfacedblist = [];
  late List<ERPAccessModel>? _Erpaccesslist = [];
  String wifiaccessvalue = "";
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;
  location.LocationData?  locationData;
 // late DatabaseHelper dbHelper;
  Future<String> get _localPath async {
    Directory dir = Directory('/storage/emulated/0/Download');
    print(dir.path);
    return dir.path;

   // return directory.path;
  }

  Future<File> get _localFile_andi async {


      final path = await _localPath;
      return File('$path/face_rec_ess.db');


/*
    else if(Platform.isIOS){
    Directory documents = await getApplicationDocumentsDirectory();
    final path = documents.path;
    jsonFile = new File(path);
    return jsonFile;
    }*/


  }
  Future<File> get _localFile_ios async {


    Directory documents = await getApplicationDocumentsDirectory();
    final path = documents.path;
    return File('$path/face_rec_ess.db');


  }

  Future<List<User>> sampleData(Database db) async
  {
   // Database db = await this.database;
   /* List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT * FROM face_rec_ess_table');*/
    var result = await db.rawQuery('SELECT * FROM face_rec_ess_table');
    print("object"+result.toString());
    for (var n in result)
    {
      //("NNN==>"+n['map_key_data']['extra'].toString());
     // print('map_key_data==>'+n['map_key_data'].toString());
      final parsedJson = n['map_key_data'];
      Map<String, dynamic> map = jsonDecode(parsedJson.toString());

      //String str= '0a130486-3e0d-422a-a0c7-e5712385dca8';
      String str= PreferenceUtils.getString("EmployeeId");
      final parsedJson1 = map[str];
      print(map[str]);
      print('data==>'+parsedJson1['extra'][0].toString());


      User user =new User(name: n['emp_name'].toString(),emp_id: n['emp_id'].toString(),desination: n['designation'].toString(),array: parsedJson1['extra'][0]);
      listuser.add(user);
    }


    return listuser;
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


  Future<void> writeContent(List<User> users) async {
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    print("embpath==>"+_embPath);
    jsonFile = new File(_embPath);
    // Write the file
    jsonFile!.writeAsStringSync(json.encode(users));
  }

  Future<bool> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = url;
      print('myUrl==>'+myUrl);
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      print(response.statusCode);
      if(response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
        return true;
      }
      else{
        filePath = 'Error code: '+response.statusCode.toString();
        print(filePath);
        return false;

      }

    }
    catch(ex){
      print(ex.toString());
      filePath = 'Can not fetch url';
      print(filePath);
      return false;

    }
    return false;
    //return filePath;
  }

  Future getBLES_ScanPermission() async {

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    int? androidversion =  androidInfo.version.sdkInt;
    if(Platform.isAndroid && androidversion! >= 31){
      PermissionStatus status2 = await Permission.bluetoothConnect.request();
      PermissionStatus status1 = await Permission.bluetoothScan.request();
      if (status2.isGranted && status1.isGranted) {
        return true;
      } else if (status2.isPermanentlyDenied || status1.isPermanentlyDenied) {
        await openAppSettings();
      } else if (status2.isDenied || status1.isDenied ) {
        print('Permission Denied');
      }
    }

  }
  Future getStoragePermission() async {

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
     int? androidversion =  androidInfo.version.sdkInt;
     if(Platform.isAndroid && androidversion! >= 30){
       PermissionStatus status2 = await Permission.manageExternalStorage.request();
       if (status2.isGranted) {
         return true;
       } else if (status2.isPermanentlyDenied) {
         await openAppSettings();
       } else if (status2.isDenied) {
         print('Permission Denied');
       }
     }else{
       PermissionStatus status = await Permission.storage.request();
       if (status.isGranted) {
         return true;
       } else if (status.isPermanentlyDenied) {
         await openAppSettings();
       } else if (status.isDenied) {
         print('Permission Denied');
       }
     }

    //PermissionStatus status1 = await Permission.accessMediaLocation.request();



  }

  Future locationStatus(BuildContext context) async {
    if(!await IsLocationEnable()){
     return await handleOpenLocationSettings(context);
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    listuser.clear();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {

     // setState(() => _source = source);
      final abc = NavigationService.navigatorKey.currentContext;
      Provider.of<DrawerItemRow>(abc!,listen: false).updateSource(source);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // your method where use the context
      // Example navigate:
      final abc = NavigationService.navigatorKey.currentContext;
    //  locationStatus(abc).then((value) => {})
        if(Provider.of<DrawerItemRow>(abc!,listen: false).isregister){
          Provider.of<DrawerItemRow>(abc,listen: false).updateisPleaseWaitShow(true);
          PunchHere(abc);
        }
    });


   // print(_permissionReady);
   // getfile_fromserver();


   /* Future<List<User>> data=readContent();
    data.then((value) => {
      setState(() {
        listuser = value;
        writeContent(listuser);
      })

    });*/


  }
  Future<bool> getDownloadFile(List<UserFaceDb_Model> _userfacedblist) async{


    if(_userfacedblist.length>0){
      print(_userfacedblist[0].uRL);
      String? download_url = _userfacedblist[0].uRL;
      final dir = await _localPath;
      final result = await downloadFile(download_url!, "face_rec_ess.db", dir);
      print('Result==>'+result.toString());
      return result;
    }

    /* bool _permissionReady = await _checkPermission();
   if(_permissionReady){

   }*/


  return false;

  }
  Future<bool> getfile_fromserver() async{

    String connection_url=PreferenceUtils.getString("connection_url");
    String EmployeeId=PreferenceUtils.getString("EmployeeId");
    _userfacedblist = await ApiService().getFacefb_file(connection_url, EmployeeId);
    //_userfacedblist = List<UserFaceDb_Model>.from(data as Iterable);
    //print(_userfacedblist?.length);
   /* print(_userfacedblist![0].uRL);
    String? download_url = _userfacedblist![0].uRL;
    final dir = await _localPath;
    final result = await downloadFile(download_url!, "face_rec_ess.db", dir);
    print('Result==>'+result.toString());*/
  /* bool _permissionReady = await _checkPermission();
   if(_permissionReady){

   }*/
    if(_userfacedblist!.length>0)
    {
      return true;
    }else{
      return false;
    }



  }
/*  void call_fetchDataFromServer(){
    Future<List<User>> data=readContent();
    data.then((value) => {
      setState(() {
        listuser = value;
        writeContent(listuser);
      })

    });
  }*/
  bool UpdateBeconDialog(BuildContext context){
    if(Provider.of<DrawerItemRow>(context,listen: false).InBeconmode == "deactive")
      return true;
    else if(Provider.of<DrawerItemRow>(context,listen: false).InBeconmode == "active")
      return false;
    else
      return false;
  }
 Future<bool> IsLocationEnable() async {
   //return await flutterBeacon.openLocationSettings;
   return await Permission.locationWhenInUse.serviceStatus.isEnabled;
  }
  handleOpenLocationSettings(BuildContext context) async {
    if (Platform.isAndroid) {
      await flutterBeacon.openLocationSettings;
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location Services Off'),
            content: Text(
              'Please enable Location Services on Settings > Privacy > Location Services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> ErrorDialog(BuildContext context,String title,String message) async {
    await showDialog(
        context: context,
        builder: (context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(fontSize: 16,fontFamily: ApiConstants.fontname,color: Colors.black87),),
        content: Text(
          message,
          style: TextStyle(fontSize: 14,fontFamily: ApiConstants.fontname,color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(fontSize: 14,fontFamily: ApiConstants.fontname,color: Colors.black87),),
          ),
        ],
      );
    },
    );
  }
  Future<void> RegisterUserTask(BuildContext context) async {

    if(Platform.isAndroid){
      var file = await _localFile_andi;
      if(_isurldbfile){

        _permissionReady = await getStoragePermission();
        print(_permissionReady);
        if(_permissionReady){
          var isdownload = await getDownloadFile(_userfacedblist!);
          print('isdownload==>'+isdownload.toString());
          if(isdownload){
            final downloadfile = await _localFile_andi;

            file = downloadfile;
            print('abc-->'+file.path);
          }

          var databasesPath = await getDatabasesPath();
          print("db_path1==>"+databasesPath.toString());
          var path = join(databasesPath, "face_rec_ess.db");
          print("db_path2==>"+path.toString());

          var exists = await databaseExists(path);
          print("exists==>"+exists.toString());

          // final file = getSomeCorrectFile(); // File
          final bytes_ = await file.readAsBytes(); // Uint8List
          final data = bytes_.buffer.asByteData(); // ByteData
          List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

          // Write and flush the bytes written
          await File(path).writeAsBytes(bytes, flush: true);

          var bomDataTable = await openDatabase(path, readOnly: true);
          print("exists1==>"+ bomDataTable.toString());
          listuser = await sampleData(bomDataTable);
          listuser  //convert list data  to json
              .map(
                (player) => player.toJson(),
          )
              .toList();
          print("data_read==>"+json.encode(listuser));
          //print("data_read==>"+listuser[0].name);

          for(var i in listuser){
            print(i.emp_id);
            print(i.name);
            print(i.desination);
            print(i.array);
          }
          await writeContent(listuser);
          //api ErpAccess
          // String EmployeeId=PreferenceUtils.getString("EmployeeId");
          // _Erpaccesslist = await ApiService().getERPAcess(EmployeeId);
          /* if(_Erpaccesslist!.length>0){

          if(!await IsLocationEnable()){
           await handleOpenLocationSettings(context);
           ERPAcessProcess(_Erpaccesslist!,context);
          }else{
            ERPAcessProcess(_Erpaccesslist!,context);
          }

        }*/
        }

      }
    }else if(Platform.isIOS) {
      var file = await _localFile_ios;
       if(_isurldbfile) {
          var isdownload = await getDownloadFile(_userfacedblist!);
          print('isdownload==>'+isdownload.toString());
                if(isdownload){
                  final downloadfile = await _localFile_andi;

                  file = downloadfile;
                  print('abc-->'+file.path);
              }
          var databasesPath = await getDatabasesPath();
          print("db_path1==>"+databasesPath.toString());
          var path = join(databasesPath, "face_rec_ess.db");
          print("db_path2==>"+path.toString());

          var exists = await databaseExists(path);
          print("exists==>"+exists.toString());

          // final file = getSomeCorrectFile(); // File
          final bytes_ = await file.readAsBytes(); // Uint8List
          final data = bytes_.buffer.asByteData(); // ByteData
          List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

          // Write and flush the bytes written
          await File(path).writeAsBytes(bytes, flush: true);

          var bomDataTable = await openDatabase(path, readOnly: true);
          print("exists1==>"+ bomDataTable.toString());
          listuser = await sampleData(bomDataTable);
          listuser  //convert list data  to json
              .map(
                (player) => player.toJson(),
          )
              .toList();
          print("data_read==>"+json.encode(listuser));
          //print("data_read==>"+listuser[0].name);

          for(var i in listuser){
            print(i.emp_id);
            print(i.name);
            print(i.desination);
            print(i.array);
          }
          await writeContent(listuser);

     }
    }


  }
  Future<void> PunchHere(BuildContext context) async {
    String EmployeeId=PreferenceUtils.getString("EmployeeId");
    _Erpaccesslist = await ApiService().getERPAcess(EmployeeId);
    if(_Erpaccesslist!.length>0){
      Provider.of<DrawerItemRow>(context,listen: false).updateisPleaseWaitShow(false);
      if(!await IsLocationEnable()){
          final service = LocationService();
           bool ison =  await service.CheckPermission();
           if(ison){
             ERPAcessProcess(_Erpaccesslist!,context);
           }

    }else{
    ERPAcessProcess(_Erpaccesslist!,context);
    }

  }else{
      //Provider.of<DrawerItemRow>(context,listen: false).updateisPleaseWaitShow(false);
    }
  }
  Future<void> ERPAcessProcess(List<ERPAccessModel> _Erpaccesslist,BuildContext context) async {

    if(_Erpaccesslist[0].status.toString() == 'Approved'){

      if(_Erpaccesslist[0].accessTo.toString() == "Wifi"){
        wifiaccessvalue = _Erpaccesslist[0].accessValue.toString();

        print(wifiaccessvalue);
        _connectivity.initialise();
        _connectivity.myStream.listen((source) {

          setState(() => _source = source);

          switch (_source.keys.toList()[0]) {
            case ConnectivityResult.mobile:
              var string =
              _source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
              print(string);
              initWifiMode(context,wifiaccessvalue);
              break;
            case ConnectivityResult.wifi:
              var string =
              _source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
              print(string);
              initWifiMode(context,wifiaccessvalue);
              break;
            case ConnectivityResult.none:
            default:
              var string = 'Offline';
              print(string);
          }
        });

      /*  _source = Provider.of<DrawerItemRow>(context,listen: false).source;
        switch (_source.keys.toList()[0]) {
          case ConnectivityResult.mobile:
            var string = 'Mobile: Online';
            print(string);
            initWifiMode(context,wifiaccessvalue);
            break;
          case ConnectivityResult.wifi:
            var string = 'WiFi: Online';
            print(string);
            initWifiMode(context,wifiaccessvalue);
            break;
          case ConnectivityResult.none:
          default:
          var string = 'Offline';
          print(string);
        }*/


      }else if(_Erpaccesslist[0].accessTo.toString() == "Beacon"){

        if(await getBLES_ScanPermission()){
          bool ison = await flutterBeacon.openBluetoothSettings;
          if(ison){
            initScanBeacon(context,_Erpaccesslist[0].uUID.toString());
          }

        }
      }else{
        //any
        Provider.of<DrawerItemRow>(context,listen: false).updateisPleaseWaitShow(true);
        locationData = await LocationService().getLocation();
        if(locationData!=null){
          Provider.of<DrawerItemRow>(context,listen: false).updateisPleaseWaitShow(false);
          print("latitude->"+locationData!.latitude.toString());
          print("longitude->"+locationData!.longitude.toString());
          Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(true);
        }else{
        //  Provider.of<DrawerItemRow>(context,listen: false).updateisPleaseWaitShow(true);
          Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(false);
        }


      }
    }

  }
/*  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
    });
  }*/
  initWifiMode(BuildContext context,String accessvalue) async{

    final info = NetworkInfo();
    final wifiBSSID = await info.getWifiBSSID();
    var tempbssid = wifiBSSID;
    if (tempbssid != null) {
      print('Bssid->'+tempbssid);
      var len = tempbssid ?? ""; // Safe
      print('len-->'+len);
      if(len!=null || len.isNotEmpty){

        print('len-->'+len);

        if(len.contains(accessvalue.toString())){
          Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(true);
          Provider.of<DrawerItemRow>(context,listen: false).updatewifimode("active");
          print('len-->'+len);
        }else{
          //ErrorDialog(context,"Wifi Services Error","You are not in Office, Please connect office network.");
          Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(false);
          Provider.of<DrawerItemRow>(context,listen: false).updatewifimode("deactive");
        }
      }else{
        // ErrorDialog(context,"Wifi Services Error","You are not in Office, Please connect office network.");
        Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(false);
        Provider.of<DrawerItemRow>(context,listen: false).updatewifimode("deactive");
      }

    }else{
      // ErrorDialog(context,"Wifi Services Error","You are not in Office, Please connect office network.");
      Provider.of<DrawerItemRow>(context,listen: false).UpdateUser(false);
      Provider.of<DrawerItemRow>(context,listen: false).updatewifimode("deactive");
    }
  }
  initScanBeacon(BuildContext context,String UUID) async {
    final provider = Provider.of<DrawerItemRow>(context,listen: false);
    await flutterBeacon.initializeScanning;
    if(!await IsLocationEnable() && !provider.bluetoothEnabled){
      return;
    }
    final regions = <Region>[
      Region(
        identifier: 'ibeacon',
        proximityUUID: UUID,
      ),

    ];
    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }

    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult  result) {
      if(mounted){
        if(result.beacons.length>0){
          print('print->'+result.beacons[0].proximityUUID);
          if(result.beacons[0].proximityUUID.toLowerCase() == UUID.toLowerCase()){
            provider.UpdateUser(true);
            Provider.of<DrawerItemRow>(context,listen: false).updatebeconemode("active");
            _streamRanging?.cancel();
          }else{
            provider.UpdateUser(false);
            Provider.of<DrawerItemRow>(context,listen: false).updatebeconemode("deactive");
          }
        }else{
          provider.UpdateUser(false);
          Provider.of<DrawerItemRow>(context,listen: false).updatebeconemode("deactive");
        }

      }
    });
  }
  final ButtonStyle flatButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Color(0xff407AFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
  );
  Widget bodymethod(BuildContext context){
   /* if(mounted){
      var isregisterstr=PreferenceUtils.getString("isregister");
      if(isregisterstr.length>0){
        Provider.of<DrawerItemRow>(context,listen: false).updateRegisterState(true);
      }
    }*/

   print('_isregister-->'+Provider.of<DrawerItemRow>(context,listen: false).isregister.toString());
    if(!Provider.of<DrawerItemRow>(context,listen: false).isregister){
      print("10");
       return BiomatricView(context);
    }else if(Provider.of<DrawerItemRow>(context,listen: false).isregister){
      print("2");
      return BiomatricView(context);

    }else{
      print("3");
      return Container();
    }


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
  Widget BiomatricView(BuildContext context){
      return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Consumer<DrawerItemRow>(builder: (context,model,child){
            return  Visibility(
              visible: !model.isregister,
              child: Container(
                margin: EdgeInsets.only(left: 25,right: 25),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(

                    style: flatButtonStyle,
                    onPressed: () async {
                      /* Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SecondScreen()));*/
                      if(model.isregister){

                      }else{
                        DialogBuilder(context).showLoadingIndicator('');
                        bool value = await getfile_fromserver();
                        if (value)
                        {
                          setState(()  {
                            _isurldbfile = value;

                          });
                          await RegisterUserTask(context);
                          DialogBuilder(context).hideOpenDialog();
                          /*  Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondScreen()));*/
                          model.updateRegisterState(true);
                          PreferenceUtils.setString("isregister", "1");
                          // PunchHere(context);
                        }
                        else
                        {
                          setState(() {
                            _isurldbfile = value;
                          });
                        }
                        if(model.isregister){
                          PunchHere(context);
                        }
                      }

                    },
                    child: Text('Register for Biometrics',style: TextStyle(fontSize: 18,color: Colors.white,fontFamily: ApiConstants.fontname),),
                  ),
                ),
              ),
            );
          }),

          Consumer<DrawerItemRow>(builder: (context,model,child){
            return Visibility(
                visible:  model.isPleaseWaitShow,
                child: ProgressIndicator(context,"Please wait...")
            );
          }),
          Consumer<DrawerItemRow>(builder: (context,model,child){
            return Visibility(
                visible: model.Inwifimode == 'deactive' ? true :  model.Inwifimode == 'active' ? false : false,
                child: ProgressIndicator(context,"Please Connect In Office Network")
            );
          }),
          Consumer<DrawerItemRow>(builder: (context,model,child){
            return Visibility(
                visible: UpdateBeconDialog(context),
                child: ProgressIndicator(context,"Finding Nearby Beacon..")
            );
          }),

          PunchHereButton(context),

        /*  Visibility(
              visible:  Provider.of<DrawerItemRow>(context,listen: false).isregister,
              child: ERP_AccessView(context,"Please Wait..")
          )*/


        ],


      ),
    );

  }

  Widget PunchHereButton(BuildContext context){
    
    return Consumer<DrawerItemRow>(builder: (context,model,child){
      return Visibility(
        visible: model.isValidateUser,
        child: Container(
          margin: EdgeInsets.only(left: 25,right: 25),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(

              style: flatButtonStyle,
              onPressed: () async {
                /* Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SecondScreen()));*/
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SecondScreen()));

              },
              child: Text('Punch Here',style: TextStyle(fontSize: 18,color: Colors.white,fontFamily: ApiConstants.fontname),),
            ),
          ),
        ),
      );
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
        title: Text('Time Keeping',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w400),),
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
      body: bodymethod(context),
    );
  }
  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }
}

class MyConnectivity {
  MyConnectivity._();


  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    if(!_controller.isClosed)
      _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}

