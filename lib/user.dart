class User {
  static const String nameKey = "name";
  static const String arrayKey = "user_array";
  static const String emp_id_key = "emp_id";
  static const String desination_key = "desination";

  String? name,emp_id,desination;
  List? array;

  User({this.name, this.array,this.emp_id,this.desination});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    array = json['user_array'];
    emp_id = json['emp_id'];
    desination = json['desination'];
   // hobby = json['hobby'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['user_array'] = this.array;
    data['emp_id'] = this.emp_id;
    data['desination'] = this.desination;
   // data['hobby'] = this.hobby;

    return data;
  }
}
