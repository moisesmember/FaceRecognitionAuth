import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:face_net_authentication/services/api/api.dart';

class DataBaseService {
  // singleton boilerplate
  static final DataBaseService _cameraServiceService =
      DataBaseService._internal();

  factory DataBaseService() {
    return _cameraServiceService;
  }
  // singleton boilerplate
  DataBaseService._internal();
  Api api = new Api();

  /// file that stores the data on filesystem
  File jsonFile;

  /// Data learned on memory
  Map<String, dynamic> _db = Map<String, dynamic>();
  Map<String, dynamic> get db => this._db;

  /// loads a login.
  Future valideLogin(List predictedData) async{
    var body = '{"imagem": ${predictedData}}';
    var result = await api.makePostRequest('verificarLogin', body);
    return result;
  }

  /// [Name]: name of the new user
  /// [Data]: Face representation for Machine Learning model
  Future saveData(String user, String password, List modelData) async {
    String userAndPass = user + ':' + password;
    _db[userAndPass] = modelData;
    var body = '{"usuario": "${user}", "credencial": ${modelData}}';
    await api.makePostRequest('insertCredencial', body); // To save in MongoDB by NodeJs
    //jsonFile.writeAsStringSync(json.encode(_db));
  }

  /// deletes the created users
  cleanDB() {
    //this._db = Map<String, dynamic>();
    //jsonFile.writeAsStringSync(json.encode({}));
  }
}
