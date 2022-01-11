import 'package:flutter/material.dart';

class User {
  String user;
  String password;
  List<double> imagem;

  User({@required this.user, @required this.password, this.imagem});

  static User fromDB(String dbuser) {
    return new User(user: dbuser.split(':')[0], password: dbuser.split(':')[1]);
  }

  factory User.fromJson(Map<String, dynamic> usersjson) => User(
        user:   usersjson["usuario"],
        imagem: new List<double>.from(usersjson["imagem"])
      );

}
