import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:face_net_authentication/pages/db/database.dart';
import 'package:camera/camera.dart';
import 'package:face_net_authentication/services/image_converter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class FaceNetService {
  // singleton boilerplate
  static final FaceNetService _faceNetService = FaceNetService._internal();

  factory FaceNetService() {
    return _faceNetService;
  }
  // singleton boilerplate
  FaceNetService._internal();

  DataBaseService _dataBaseService = DataBaseService();

  Interpreter _interpreter;

  double threshold = 1.0;

  List _predictedData;
  List get predictedData => this._predictedData;

  //  saved users data
  dynamic data = {};

  Future loadModel() async {
    Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          false,
          TfLiteGpuInferenceUsage.fastSingleAnswer,
          TfLiteGpuInferencePriority.minLatency,
          TfLiteGpuInferencePriority.auto,
          TfLiteGpuInferencePriority.auto,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(true, TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      this._interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
      print('model loaded successfully');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  setCurrentPrediction(CameraImage cameraImage, Face face) {
    /// crops the face from the image and transforms it to an array of data
    List input = _preProcess(cameraImage, face);

    /// then reshapes input and ouput to model format 🧑‍🔧
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    /// runs and transforms the data 🤖
    this._interpreter.run(input, output);
    output = output.reshape([192]);

    this._predictedData = List.from(output);
  }

  /// takes the predicted data previously saved and do inference
  Future<String> predict() async{
    print("§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§");
    print(await _searchResult(this._predictedData));
    print("§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§");
    var search = await _searchResult(this._predictedData);

    /// search closer user prediction if exists
    return search.toString();
  }

  /// _preProess: crops the image to be more easy
  /// to detect and transforms it to model input.
  /// [cameraImage]: current image
  /// [face]: face detected
  List _preProcess(CameraImage image, Face faceDetected) {
    // crops the face 💇
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    // transforms the cropped face to array data
    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  /// crops the face from the image 💇
  /// [cameraImage]: current image
  /// [face]: face detected
  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  /// converts ___CameraImage___ type to ___Image___ type
  /// [image]: image to be converted
  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img, -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    /// input size = 112
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);

        /// mean: 128
        /// std: 128
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  /// searchs the result in the DDBB (this function should be performed by Backend)
  /// [predictedData]: Array that represents the face by the MobileFaceNet model
  Future<String> _searchResult(List predictedData) async{

    var result = await _dataBaseService.valideLogin(predictedData) ;
    print('****************** Função SEARCH RESULT *****************');
    print(result);
    print(result[0]['USUARIO']);
    print('*********************************************************');
    return result[0]['USUARIO'];
    //return returnResult().toString();
    /*_dataBaseService.valideLogin(predictedData).then((Map<String, dynamic> result){
      print('****************** Função SEARCH RESULT *****************');
      print(result['USUARIO']);
      print('*********************************************************');
      label = result['USUARIO'];
    });
    return label;*/
  }

  Future<Null> returnResult() async{
    Map<String, dynamic> result = await _dataBaseService.valideLogin(predictedData);
    return result['USUARIO'];
  }

  /*
  /// searchs the result in the DDBB (this function should be performed by Backend)
  /// [predictedData]: Array that represents the face by the MobileFaceNet model
  String _searchResult(List predictedData) {
    Map<String, dynamic> data = _dataBaseService.db;
    /// if no faces saved
    if (data?.length == 0) return null;
    double minDist = 999;
    double currDist = 0.0;
    String predRes;

    /// search the closest result 👓
    for (String label in data.keys) {
      currDist = _euclideanDistance(data[label], predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    return predRes;
  }

  String _searchResult(List predictedData) {
    Map<String, dynamic> data = _dataBaseService.db;
    /// if no faces saved
    if (data?.length == 0) return null;
    double minDist = 999;
    double currDist = 0.0;
    String predRes;

    /// search the closest result 👓
    for (String label in data.keys) {
      print('****************** Função SEARCH RESULT *****************');
      print(label);
      print('*********************************************************');
      //print(data[label]);
      print(data[label]);

      currDist = _euclideanDistance(convertStringToList(data[label]), predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    return predRes;
  }

  /// Adds the power of the difference between each point
  /// then computes the sqrt of the result 📐
  double _euclideanDistance(List e1, List e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  // To convert String to List<dynamic>
  List<dynamic> convertStringToList( String valueString ){
    List<dynamic> newValue = [];
    valueString = valueString.replaceAll('[', ' ');
    valueString = valueString.replaceAll(']', ' ');
    valueString.split(',').map((String number) => newValue.add( double.parse(number))).toList();
    //print(valueString);
    //print(newValue);
    return newValue;
  }
*/
  void setPredictedData(value) {
    this._predictedData = value;
  }

}
