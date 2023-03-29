import 'package:Face_recognition/Attendance_Code.dart';
import 'package:Face_recognition/Employee_Directory.dart';
import 'package:Face_recognition/Holidays.dart';
import 'package:Face_recognition/Homepage.dart';
import 'package:Face_recognition/LoginDemo.dart';
import 'package:Face_recognition/MyProfile.dart';
import 'package:Face_recognition/PucnVerify.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/provider/DrawerItemRow.dart';
import 'package:Face_recognition/provider/Emp_directory_provider.dart';
import 'package:Face_recognition/register.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ConnectionCodePage.dart';
import 'DashBoardPage.dart';
import 'DatabaseHelper.dart';
import 'NavigationService.dart';
import 'SplashPage.dart';


final dbHelper = DatabaseHelper();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  await PreferenceUtils.init();
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawerItemRow()),
        ChangeNotifierProvider(create: (_) => Emp_directory_provider()),
      ],
      child:  MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        themeMode: ThemeMode.light,
        theme: ThemeData(brightness: Brightness.light),
        initialRoute: "/",
        title: "Face Recognition",
        debugShowCheckedModeBanner: false,

        routes: {
          '/': (context) => const SPlashPage(),
          '/second': (context) => const Employee_Directory(),
          '/register': (context) => const Register(),
          '/myprofile': (context) => const MyProfile(),
          '/holidays': (context) => const Holidays(),
          '/attendance_code': (context) => const Attendance_Code(),

        },
      ),
    );
  }
}



