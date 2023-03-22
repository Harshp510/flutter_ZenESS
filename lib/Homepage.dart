import 'dart:convert';
import 'dart:io';
import 'package:Face_recognition/main.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/provider/DrawerItemRow.dart';
import 'package:Face_recognition/user.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'LocationService.dart';
import 'MyProfile.dart';
import 'NavigationService.dart';
import 'PucnVerify.dart';
import 'SlideRightRoute.dart';
import 'detector_painters.dart';
import 'utils.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  State<SecondScreen> createState() => _SecondScreen();
}

class _SecondScreen extends State<SecondScreen> {
  File? jsonFile;
  dynamic _scanResults;
  CameraController? _camera;
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  // dynamic data = {};
  double threshold = 0.7;
  Directory? tempDir;
  List? e1;
  List<User> list_user = [];
  List<CameraDescription>? cameras;
  bool _faceFound = false;
  late DateTime current_date;
  final TextEditingController _name = new TextEditingController();
  String str_display_name="";
  LocationData? _locationData;
  @override
  void initState() {
    super.initState();
   // WidgetsBinding.instance?.addObserver(this as WidgetsBindingObserver);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final abc = NavigationService.navigatorKey.currentContext;

    _initializeCamera(abc!);
    Provider.of<DrawerItemRow>(abc,listen: false).updateLastPunched("");
  }
  @override
  void dispose() {
    if (_camera != null) {
      debugPrint('camera controller is null or not initialized');
      try {
        _camera?.dispose();
      } catch (e) {
        debugPrint(e.toString());
      }
    }

  //  WidgetsBinding.instance?.removeObserver(this as WidgetsBindingObserver);
    super.dispose();
  }
  Future loadModel() async {
    print("load");
    try {
      final gpuDelegateV2 = tfl.GpuDelegateV2(
        options: tfl.GpuDelegateOptionsV2(),
        // options: tfl.GpuDelegateOptionsV2(
        //   false,
        //   tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
        //   tfl.TfLiteGpuInferencePriority.minLatency,
        //   tfl.TfLiteGpuInferencePriority.auto,
        //   tfl.TfLiteGpuInferencePriority.auto,
        // ),
      );

      var interpreterOptions = tfl.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
    //  interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite',options: interpreterOptions);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite');
    } on Exception {
      print('Failed to load model.');
    }
  }
  Future<List<User>> readPlayerData (File file) async {


    String contents = await file.readAsString();
    var jsonResponse = jsonDecode(contents);

    print(jsonResponse);
    for(var p in jsonResponse){
    //  print(p['user_name']);
      User player = User(name:p['name'],array:p['user_array'],emp_id:p['emp_id'],desination: p['desination']);
      list_user.add(player);
    }

    return list_user;
  }
  void _initializeCamera(BuildContext context) async {
    await loadModel();
    cameras = await availableCameras();
    CameraDescription description = await getCamera(_direction);

    InputImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera =
        CameraController(description, ResolutionPreset.high);

    await _camera!.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    print("embpath==>"+_embPath);
    jsonFile = new File(_embPath);
    list_user.clear();
    if (jsonFile!.existsSync())
      list_user = await readPlayerData(jsonFile!);





    list_user  //convert list data  to json
        .map(
          (player) => player.toJson(),
    )
        .toList();
    //e1 = list_user[0].array;
    print("data_read_home==>"+json.encode(list_user));
    print("data_read_home==>"+list_user.length.toString());
   // print("data_read_e1==>"+e1.toString());



    _camera!.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        String res="";
        String res_name="";
       // User? res_user;
        dynamic finalResult = Multimap<String, Face>();
        print('finalResult==>'+finalResult.toString());
        detect(image, _getDetectionMethod(), rotation).then(
              (dynamic result) async {
            if (result.length == 0)
              _faceFound = false;
            else
              _faceFound = true;
            Face _face;
            imglib.Image convertedImage =
            _convertCameraImage(image, _direction);
            for (_face in result) {
              double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 10);
              h = (_face.boundingBox.height + 10);
              imglib.Image croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              // int startTime = new DateTime.now().millisecondsSinceEpoch;
              res = _recog(croppedImage);
              print('res-->'+res);
              if(res == "NOT RECOGNIZED"){
                setState(() {
                  str_display_name=res;
                });
                finalResult.add(res, _face);

              }else{
                if(Provider.of<DrawerItemRow>(context,listen: false).lastPunch != res){
                  print('notsame newface');
                  LocationService().getLocation().then((location) =>{
                    setState(() {
                      _locationData=location;
                    })
                  });
                  dbHelper.getEmployeeName(res).then((value) => {
                    res_name = value,
                    setState(() {
                      str_display_name=res_name;
                    })

                  });
                  print('res2-->'+res_name);

                  finalResult.add(str_display_name, _face);
                  _camera?.pausePreview();
                  Provider.of<DrawerItemRow>(context,listen: false).updateLastPunched(res);
                  Future.delayed(Duration(milliseconds: 2000),()
                  {
                    //final abc = NavigationService.navigatorKey.currentContext;
                    //Navigator.pushNamed(abc!, "/second");
                    if(_locationData!=null){
                      Navigator.pushReplacement(context, SlideRightRoute(page: PuchVerify(emp_id: res,latitude:_locationData!.latitude ,longitude: _locationData!.longitude,)));
                    }



                  });
                }else{
                  print('alread same');
                }

              }

              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Inference took ${endTime - startTime}ms");

            }
            setState(() {


                _scanResults = finalResult;



            });

            _isDetecting = false;
          },
        ).catchError(
              (_) {
            print("error");
            _isDetecting = false;
          },
        );
      }
    });
  }

  HandleDetection _getDetectionMethod() {
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    if (_camera == null || !_camera!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_camera!),
          _buildResults(),

          Positioned(child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [

                  Expanded(
                    child: Container( padding:EdgeInsets.all(10),child: Text(str_display_name,
                      style: TextStyle(color: Colors.indigo,fontSize: 16,fontWeight: FontWeight.w500),)),
                    flex: 1,
                  ),
                  Row(

                    children: [
                      Expanded(
                        child: Container( padding:EdgeInsets.all(10),decoration: BoxDecoration(color: Colors.indigo),child: Text('Please look at camera',
                          style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500),)),
                        flex: 2,
                      ),
                      Expanded(
                        child: Container(padding:EdgeInsets.all(10),decoration: BoxDecoration(color: Colors.indigo),child: Text(GetDate_Data(),textAlign: TextAlign.end,style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500,)),),
                        flex: 2,
                      ),

                      /*Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(color: Colors.indigo),
                          child:Text('Please look at camera',
                            style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500),)
                        ),
                      ),

                      Flexible(
                        flex: 1,
                        child: Container(
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(color: Colors.indigo),
                            child:Text(greetingMessage(),textAlign: TextAlign.end,style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500,)
                        )
                        ),
                      )*/
                    ],
                  ),
                  SizedBox(height: 1,),
                  Expanded(
                    child: Container(
                        width: double.infinity,
                        padding:EdgeInsets.all(10),decoration: BoxDecoration(color: Colors.indigo),child: Text(PreferenceUtils.getString("Emp_Location"),textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500),)),
                    flex: 1,
                  ),
                ],
              ),

            ),
          ))
        ],
      ),
    );
  }

/*  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera!.stopImageStream();
    await _camera!.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }*/

  String GetTime_Data()  {
    current_date = DateTime.now();
    return DateFormat('hh:mm:ss aa').format(current_date);
  }
  String GetDate_Data()  {
    current_date = DateTime.now();
    return DateFormat('dd-MM-yyyy').format(current_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: Row(
          children: [
            Text('Time Keeping',
              style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w500),),
            Spacer(),
            Center(
                child: Text(GetTime_Data(),style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500),))
          ],
        ),
       ),
      body: _buildImage(),
      floatingActionButton:
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
       /* FloatingActionButton(
          backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
          child: Icon(Icons.add),
          onPressed: () {
            if (_faceFound) _addLabel();
          },
          heroTag: null,
        ),
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          onPressed: _toggleCameraDirection,
          heroTag: null,
          child: _direction == CameraLensDirection.back
              ? const Icon(Icons.camera_front)
              : const Icon(Icons.camera_rear),
        ),*/
      ]),
    );
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
   // e1 = list_user[0].array;
    return compare(e1!).toUpperCase();
  }

  String compare(List currEmb) {
    if (list_user.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (User label in list_user) {
      currDist = euclideanDistance(label.array!, currEmb);
      print('currDist==>'+currDist.toString());
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label.emp_id!;
        //predRes = label.emp_id!;
      }
    }
    print(minDist.toString() + " " + predRes);
    return predRes;
  }


 /* void _resetFile() {
    list_user.clear();
    jsonFile!.deleteSync();
  }

  void _viewLabels() {
    setState(() {
      _camera = null;
    });
    String? name;
    print("size"+list_user.length.toString());
    var alert = new AlertDialog(
      title: new Text("Saved Faces"),
      content: new ListView.builder(
          padding: new EdgeInsets.all(2),
          itemCount: list_user.length,
          itemBuilder: (BuildContext context, int index) {
            name = list_user[index].name;
            return new Column(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    name!,
                    style: new TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.all(2),
                ),
                new Divider(),
              ],
            );
          }),
      actions: <Widget>[
        new TextButton(
          child: Text("OK"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }*/

 /* void _addLabel() {
    setState(() {
      _camera = null;
    });
    print("Adding new face");
    var alert = new AlertDialog(
      title: new Text("Add Face"),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              controller: _name,
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: "Name", icon: new Icon(Icons.face)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new TextButton(
            child: Text("Save"),
            onPressed: () {
              _handle(_name.text.toUpperCase());
              _name.clear();
              Navigator.pop(context);
            }),
        new TextButton(
          child: Text("Cancel"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _handle(String text) {
    //  data[text] = e1;
    //  print("data" + data.toString());

    User user = new User(name: text,array: e1,emp_id: '0a130486-3e0d-422a-a0c7-e5712385dca8',desination: 'Android Developer');
    // user.name = text;
    // user.array = e1;
    list_user?.add(user);

    //User user =  User.fromJson(data);
    // print("data1" + user.toJson().toString());
    print("data1" + json.encode(list_user));

    list_user  //convert list data  to json
        ?.map(
          (player) => player.toJson(),
    )
        .toList();

    jsonFile!.writeAsStringSync(json.encode(list_user));
    _initializeCamera();
  }*/


  
}




class  CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final Widget child;
  final double height;

  CustomAppBar({
    required this.child,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        color: Colors.blueAccent,
        alignment: Alignment.center,
        child: child,

      ),
    );
  }
}

