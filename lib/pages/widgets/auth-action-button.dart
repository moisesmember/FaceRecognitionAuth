import 'dart:io';
import 'dart:async';
import 'package:face_net_authentication/pages/db/database.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/facenet.service.dart';
import 'package:flutter/material.dart';
import 'package:macadress_gen/macadress_gen.dart';
import '../home.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {Key key, @required this.onPressed, @required this.isLogin, this.reload});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();
  final CameraService _cameraService = CameraService();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User predictedUser;
  MacadressGen macadressGen = MacadressGen();
  String mac;

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;

    /// creates a new user in the 'database'
    await _dataBaseService.saveData(user, password, predictedData);

    /// resets the face stored in the face net sevice
    this._faceNetService.setPredictedData(null);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;

    //if (this.predictedUser.password == password) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    this.predictedUser.user,            // Passa o nome para a tela chamada
                    imagePath: _cameraService.imagePath, // Parra a foto para a tela chamada
                  )));
    /*} else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Senha incorreta!'),
          );
        },
      );
    }*/
  }

  Future getMAc() async {
    mac = await macadressGen.getMac();
    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    print(mac);
    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
  }
  Timer _debounce;

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
        future: _faceNetService.predict(), // Chama a função de predição
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<User> user){
          return InkWell(
            onTap: () async {
              try {
                this.predictedUser = null;
                // Ensure that the camera is initialized.
                await widget._initializeControllerFuture;
                // onShot event (takes the image and predict output)
                bool faceDetected = await widget.onPressed();

                if (faceDetected) { // Face detectada e botão clicado
                  if (widget.isLogin) { // Está logada
// Checking if future is resolved
                    print('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                    print(user.connectionState);
                    print('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
                    if (user.connectionState == ConnectionState.done) { // Espera finalizar
                      if (user.hasData && !user.hasError) {
                        if (user.data != null) {
                          //await getMAc();
                          //setState(() {});
                          print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
                          print(user.data.user);
                          print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

                          this.predictedUser = user.data;
                          if(user.data.user == ""){
                            print("Objeto vazio");
                            this.predictedUser = null;
                          }else{
                            //_faceNetService.setPredictedData(null);
                            this._faceNetService.clearPredictedData();
                          }
                        }
                      } else {
                        // Não possui data
                        this.predictedUser = null;
                        return CircularProgressIndicator();
                      }

                    }else{ // new test
                      this.predictedUser = null;
                    }
                  }

                  if (user.connectionState == ConnectionState.done) {
                    print(
                        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
                    print(this.predictedUser.user);
                    print(
                        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
                  }
                  print('<><><><><><><><><><><><><><><><><><><>><><><>>><>><><>><><>');
                  print('ANTES');
                  print(ConnectionState.done);
                  print('<><><><><><><><><><><><><><><><><><><>><><><>>><>><><>><><>');
                  if (_debounce?.isActive ?? false) _debounce.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {

                    print('<><><><><><><><><><><><><><><><><><><>><><><>>><>><><>><><>');
                    print(ConnectionState.done);
                    print('<><><><><><><><><><><><><><><><><><><>><><><>>><>><><>><><>');

                  });

                  PersistentBottomSheetController bottomSheetController =
                  Scaffold.of(context)
                      .showBottomSheet((context) => signSheet(context));

                  bottomSheetController.closed.whenComplete(() =>
                      widget.reload());

                }
              } catch (e) {
                // If an error occurs, log the error to the console.
                print(e);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF0F0BDB),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CAPTURAR IMAGEM',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.camera_alt, color: Colors.white)
                ],
              ),
            ),
          );
        }
    );
  }

  signSheet(context) {
    print("ºººººººººººººº CHEGOU NO SIGN SHEET ºººººººººººººººººººº");
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Bem-vindo de volta, ' + predictedUser.user + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'Usuário não encontrado 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                        controller: _userTextEditingController,
                        labelText: "Seu nome",
                      )
                    : Container(),
                SizedBox(height: 10),
                /*widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                        controller: _passwordTextEditingController,
                        labelText: "Senha",
                        isPassword: true,
                      ),
                 */
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context); // Efetua a verificação do LOGIN
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                            text: 'CADASTRAR',
                            onPressed: () async {
                              await _signUp(context);
                            },
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<String> fetchData() => Future.delayed(Duration(seconds: 8), () {
    print('Step 1, fetch data');
    return "CONCLUIDO";
  });
}
