import 'dart:convert';

import 'package:Face_recognition/Common.dart';
import 'package:Face_recognition/DialogBuilder.dart';
import 'package:Face_recognition/model/DepartmentsModel.dart';
import 'package:Face_recognition/prefrence/PreferenceUtils.dart';
import 'package:Face_recognition/provider/Emp_directory_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ApiConstants.dart';
import 'MyProfile.dart';
import 'NavDrawer.dart';
import 'SlideRightRoute.dart';
import 'model/EmployeeModel.dart';

class Employee_Directory extends StatefulWidget {
  const Employee_Directory({Key? key}) : super(key: key);

  @override
  State<Employee_Directory> createState() => _Employee_DirectoryState();
}

class _Employee_DirectoryState extends State<Employee_Directory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DepartmentsModel> departmentlist=[];
  List<EmployeeModel> allmployeelist = [];
  List<EmployeeModel> filteremployeelist = [];
  String default_department="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allmployeelist.clear();
    default_department = PreferenceUtils.getString("Emp_department");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('default_department==>'+default_department);
      final authViewModel = Provider.of<Emp_directory_provider>(context, listen: false);

      departmentlist =  await authViewModel.getDepartment();

      if(departmentlist.length>0){
        var abc = departmentlist.where(
                (x) => x.departmentName.toString().toLowerCase().contains(default_department.toLowerCase())).toList();
        print(abc[0].departmentName);
        authViewModel.SetselectedDepartment(abc[0]);
        allmployeelist = await authViewModel.getEmp_list(PreferenceUtils.getString('EmployeeId'));
        filteremployeelist = allmployeelist
            .where((user) =>
            user.departmentName.toString().toLowerCase().contains(abc[0].departmentName.toString().toLowerCase()))
            .toList();
        authViewModel.UpdateEmp_list(filteremployeelist);
      }


    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        title: Text('Employee Directory',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w400),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu,color: Colors.black87,), onPressed: () { _scaffoldKey.currentState?.openDrawer();  },
        ),
        actions: [

          Container(
           padding: EdgeInsets.all(10),
            child: Row(
              children: [
                
                IconButton(onPressed: (){
                  showSearch(context: context, delegate: DataSearch(filteremployeelist));
                }, icon: Icon(Icons.search,color: Colors.black87,),),
                
                SizedBox(width: 3,),
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
      body:  MainUI(context) ,
    );
  }

  Widget MainBodyUI (BuildContext context,Emp_directory_provider emp_provider){

   // final Emp_directory_provider emp_provider = Provider.of<Emp_directory_provider>(context);
    return Column(
      children: [

          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10,left: 15,right: 15),
              width: double.infinity,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color:Color(0xffDADCE0),width: 0.5), borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: DropdownButton<DepartmentsModel>(
                isExpanded: true,
                underline: Container(),

                value: emp_provider.selectedDepartment,
                items:emp_provider.departmentlist.map((model) => DropdownMenuItem<DepartmentsModel>(
                  value: model,
                  child:Text(model.departmentName!,style: TextStyle(fontSize: 14,fontFamily: ApiConstants.fontname,color: Colors.black87),),
                )).toList(),
                onChanged:(model){
                  emp_provider.SetselectedDepartment(model!);

                  var results = emp_provider.emp_list
                      .where((user) =>
                      user.departmentName.toString().toLowerCase().contains(model.departmentName.toString().toLowerCase()))
                      .toList();
                    emp_provider.UpdateEmp_list(results);
                  //emp_provider.UpdateEmp_list(results);
                },
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: emp_provider.filter_emp_list.length,
                itemBuilder: (context,index){
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
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:  "https://ui-avatars.com/api/?name=" + emp_provider.filter_emp_list[index].empName.toString() + "&rounded=true&size=512&color=407BFF&background=d9e4fc",
                              fit: BoxFit.cover,

                            ),
                          ),


                        ),
                        title: Text(emp_provider.filter_emp_list[index].empName.toString()),
                        subtitle: Text(emp_provider.filter_emp_list[index].designation.toString()) ,
                        onTap: (){

                        },
                      )
                    ],
                  )

                );
            }),
          )

      ],

    );
  }
  Widget ProgressIndicator(BuildContext context){
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 15,),
          Text('Please Wait...')
        ],
      ),
    );
  }
  Widget MainUI(BuildContext context){
    final Emp_directory_provider emp_provider = Provider.of<Emp_directory_provider>(context);
    return Consumer<Emp_directory_provider>(builder: (context,model,child){

      if(model.isdialogshow){
        return ProgressIndicator(context);
      }else{
        return MainBodyUI(context, emp_provider);
      }

    });
  }

}

class DataSearch extends SearchDelegate<EmployeeModel>{

  final List<EmployeeModel> listExample;
  DataSearch(this.listExample);
  List<EmployeeModel> recentList = [];
  @override
  List<Widget>? buildActions(BuildContext context) {

      return [
        IconButton(onPressed: (){
          query = "";
        }, icon: Icon(Icons.clear))
      ];

  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<EmployeeModel> suggestionList = [];
    query.isEmpty
        ? suggestionList = recentList //In the true case
        : suggestionList.addAll(listExample.where(
      // In the false case
          (element) => element.empName.toString().toLowerCase().contains(query.toLowerCase()) || element.designation.toString().toLowerCase().contains(query.toLowerCase()),
    ));
    return  ListView.builder(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: suggestionList.length,
        itemBuilder: (context,index){
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
                      backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=" + suggestionList[index].empName.toString() + "&rounded=true&size=512&color=407BFF&background=d9e4fc"),

                    ),
                    title: Text(suggestionList[index].empName.toString()),
                    subtitle: Text(suggestionList[index].designation.toString()) ,
                    onTap: (){

                    },
                  )
                ],
              )

          );
        });
  }
  
}
