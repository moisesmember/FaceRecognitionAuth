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

  /// loads a simple json file.
  Future loadDB() async {
    var tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir.path + '/emb.json';

    jsonFile = new File(_embPath);

    if (jsonFile.existsSync()) {
      print(json.decode(jsonFile.readAsStringSync()));
      print('+++++++++++++++++++++++++++++++++++++++++++++++++++++');
      _db = json.decode(jsonFile.readAsStringSync());
    }
    //await loadDBNew();
  }

  Future loadDBNew() async {

    //var dados = User.fromJson(await api.makeGetRequest('findAllCredencial'));
    //_db = Map<String, dynamic>.from(Map.from(await api.makeGetRequest('findAllCredencial')));
    var dados = await api.makeGetRequest('findAllCredencial');
    print('+===================================================+');
    print(dados);
    print('+===================================================+');

    /*_db = json.decode( await api.makeGetRequest('findAllCredencial') ) as Map<String, dynamic>;
    if( _db != null ){
      print('+===================================================+');
      print(_db);
      //print(json.decode(_db));
      print('+===================================================+');
    } */
  }

  /// [Name]: name of the new user
  /// [Data]: Face representation for Machine Learning model
  Future saveData(String user, String password, List modelData) async {
    String userAndPass = user + ':' + password;
    _db[0][userAndPass] = modelData;
    var body = '{"usuario": "${user}", "credencial": ${modelData}}';
    print(body);
    print('=====================================================');
    await api.makePostRequest('insertCredencial', body); // To save in MongoDB by NodeJs
    jsonFile.writeAsStringSync(json.encode(_db));
  }

  /// deletes the created users
  cleanDB() {
    this._db = Map<String, dynamic>();
    jsonFile.writeAsStringSync(json.encode({}));
  }
}
