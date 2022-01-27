import 'package:flutter/material.dart';

class User {
  String user;
  String password;
  List<double> imagem;

  User({this.user, this.password, this.imagem});
 // User({@required this.user, @required this.password, this.imagem});

  static User fromDB(String dbuser, String password, List<double> imagem) {
    //return new User(user: dbuser.split(':')[0], password: dbuser.split(':')[1]);
    return new User(user: dbuser, password: password, imagem: imagem);
  }

  // Convert Json
  factory User.fromJson(Map<String, dynamic> usersjson) => User(
        user:   usersjson["usuario"],
        imagem: new List<double>.from(usersjson["imagem"])
      );

  // Convert to json
  Map<String, dynamic> toJson() => {
    "usuario" : user,
    "imagem"  : imagem
  };

  /*@override
  String toString(){
    return '{${this.user},${this.imagem}}';
  }*/
}
