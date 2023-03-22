import 'package:Face_recognition/LoginDemo.dart';
import 'package:Face_recognition/model/ConnectionUrlModel.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

import 'ApiService.dart';
import 'DialogBuilder.dart';
class ConnectionCodePage extends StatefulWidget
{
  @override
  _Connection_Code_Set createState() => _Connection_Code_Set();
}

class _Connection_Code_Set extends State<ConnectionCodePage>{

  TextEditingController _controller_url = new TextEditingController();
  List<ConnectionUrlModel> conn_url_check_list=[];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: main_body_method(context),
    );
  }
  
  Widget main_body_method(BuildContext context)
  {
    return Column(
      children: [
        SafeArea(
          child: Center(
            child: Container(
              width: 280,
              height: 270,
              padding: EdgeInsets.only(top: 40),
              child: Image.asset('assets/images/splash_png.png'),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0,bottom: 15.0),
            child: Text('User Login',style: TextStyle(fontSize: 20,color: Colors.black87,fontWeight: FontWeight.w500),),
          ),
        ),
        Padding(
          //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),

          padding: EdgeInsets.symmetric(horizontal: 15),
          child: SizedBox(
            height: 50,
            child: TextField(
              textAlign: TextAlign.left,
              controller: _controller_url,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(

                  border: OutlineInputBorder(),
                  labelText: 'Connection URL',
                  hintText: 'Enter Connection URL'),

            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 15),
          height: 50,
          width: 250,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(20)),
          child: TextButton(
            onPressed: () {
              _doUrl_check(context);
            },
            child: Text('Login',style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
        ),
      ],
    );
  }


  Future<void> _doUrl_check(BuildContext context) async {

    bool connection_flag= await ApiService().check_connection_network();
    print("connection_flag-->"+connection_flag.toString());

      if(connection_flag)
      {
        //print('check_net available-->'+value.toString());

        DialogBuilder(context).showLoadingIndicator('');
        String connection_url = _controller_url.text;
        // var bytes = utf8.encode(_controller_password.text);
        // var password = base64.encode(bytes);
        ApiService apiService = new ApiService();
        conn_url_check_list = await apiService.check_conn_url(connection_url);
        print('conn_urlsize-->'+conn_url_check_list.length.toString());
        if (conn_url_check_list.length > 0)
        {
          if (conn_url_check_list[0].status == "1")
          {
            PreferenceUtils.setString("connection_url", connection_url);
            DialogBuilder(context).hideOpenDialog();
            _navigateToNextScreen(context);

          }
          else{
            DialogBuilder(context).hideOpenDialog();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(conn_url_check_list[0].message.toString()),));
          }
        } else {
          DialogBuilder(context).hideOpenDialog();
          throw Exception("error");

        }

      }
      else
      {
        //print('check_net not available-->'+value.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Internet not available"),));
      }





  }

  void _navigateToNextScreen(BuildContext nextcontext) {
    Navigator.push(nextcontext,MaterialPageRoute(builder: (nextcontext) => LoginDemo()));
  }
}