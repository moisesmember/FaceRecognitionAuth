import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Api{
  static const urlPrefix = 'http://10.51.19.55:3135/facial';
  final resultNotifier = ValueNotifier<RequestState>(RequestInitial());

  Future<dynamic> makeGetRequest(String router) async {
  //Future<String> makeGetRequest() async {
      resultNotifier.value = RequestLoadInProgress();
      //final url = Uri.parse('$urlPrefix/posts');
      final url = Uri.parse('$urlPrefix/$router');
      Response response = await get(url);
      print('Status code: ${response.statusCode}');
      print('============================================');
      //print('Headers: ${response.headers}');
      print('============================================');
      //print('Body: ${response.body}');
      print('============================================');
      return _handleResponse(response);
      //return response;
    }

    Future<dynamic> makePostRequest(String router, String body) async {
      resultNotifier.value = RequestLoadInProgress();
      final url = Uri.parse('$urlPrefix/$router');
      final headers = {"Content-type": "application/json"};
      //final json = '{"title": "Hello", "body": "body text", "userId": 1}';
      final response = await post(url, headers: headers, body: body);
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      return _handleResponse(response);
      //return response;
    }

    Future<void> makePutRequest() async {
      resultNotifier.value = RequestLoadInProgress();
      final url = Uri.parse('$urlPrefix/posts/1');
      final headers = {"Content-type": "application/json"};
      final json = '{"title": "Hello", "body": "body text", "userId": 1}';
      final response = await put(url, headers: headers, body: json);
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      _handleResponse(response);
    }

    Future<void> makePatchRequest() async {
      resultNotifier.value = RequestLoadInProgress();
      final url = Uri.parse('$urlPrefix/posts/1');
      final headers = {"Content-type": "application/json"};
      final json = '{"title": "Hello"}';
      final response = await patch(url, headers: headers, body: json);
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      _handleResponse(response);
    }

    Future<void> makeDeleteRequest() async {
      resultNotifier.value = RequestLoadInProgress();
      final url = Uri.parse('$urlPrefix/posts/1');
      final response = await delete(url);
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      _handleResponse(response);
    }

    /*void _handleResponse(Response response) {
      if (response.statusCode >= 400) {
        resultNotifier.value = RequestLoadFailure();
      } else {
        resultNotifier.value = RequestLoadSuccess(response.body);
      }
    }*/
    dynamic _handleResponse(Response response){
      if (response.statusCode >= 400) {
        return  [{}] ;
      } else {
        return json.decode( response.body );
      }
    }
}

class RequestState {
  const RequestState();
}

class RequestInitial extends RequestState {}

class RequestLoadInProgress extends RequestState {}

class RequestLoadSuccess extends RequestState {
  const RequestLoadSuccess(this.body);
  final String body;
}

class RequestLoadFailure extends RequestState {}