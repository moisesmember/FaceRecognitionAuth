import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Api{
  static const urlPrefix = 'http://10.51.19.55:3135/facial';
  final resultNotifier = ValueNotifier<RequestState>(RequestInitial());

  Future<dynamic> makeGetRequest(String router) async {
      resultNotifier.value = RequestLoadInProgress();
      final headers = {"Content-type": "application/json",
                       "Authorization": "bearer eyJ0eXAiOwiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5MTYzOThhNi0xMjA4LTQ0ODYtYTBjMC0xYTFlZwmJlZGNhMTUiLCJqdGkiOiJjMWE1MDZkMzZhYTc4YmE2NDM0NGY3NzNkYWMyNzIwMTAxNzBmZjdlNTVhZjFiZWZlZWRmZDM5NGRlZDlkYTQzNzVlMjE2ODFhM2I5ZjIzMiIsImlhdCI6MTU5OTY5MjkwMiwibmJmIjoxNTk5NjkyOTAyLCJleHAiOjE2MzEywMjg5MDIsInN1wYiI6IjQiLCJzY29wZXMiOltdfQ.rN1LkEKusr8hQEooQ4PnnTjyavAG0_4br9Ypg_M4aPJ5tuB_8wakeK1DiMHeieoefwWB52jzKsWndxJVd-w19Mj57-H4VymLMFhvj8nhlTBATfhYTc0UZmI0xOo0TFbE45gE-31UKcMCw9zVLqTTZXC2IpJNSdEVEyF2GxfwPPIQRFlOWAXaOemfmMhIuInhj4W8BKSonlGJNVqumV9mXWco6grzs8rBanuVL_phwNDbfEjockBt1HQrhCo-djfJOv66drwnzHt2L-e_PZ-9dWBiawn82VOJstWk-X-RgS1I0jPq-CSYqWvkGg2MFcmzoDoEqlGAyfsbrTJkOSOVf86leN12Lk25iCiqylY5h9dvHRLs3MvV0sUicJvcSWjFcm0QdHDlzvXxTCCcDiV_cakifksePEwY3WuFsRHLIXIM64bT2EuBmF61jQ8F2I1Sf6mxPCpn5VnKi8lB_kCmdjgBM9QTV5it2ABj_7chUq0NAYtPp2AvCEP7oucpHDqmP4sczMkdFnqbHrjZvjuvZCKzIGtQfuNtx2qoK7F5zLDjnyyLZQjBxEvOK4epCmn_HGom2gnMhxoHRTUWdiT8jcjpLEYmYCB9hO2yHdvMNytpKfaL6LE30xc-BaAbklg7Sc-gkBiVJOYHpwV7t4Freij1Rj4w-nR6NycFZ7MUf6D40rx4"};
      final url = Uri.parse('$urlPrefix/$router');
      Response response = await get(url, headers: headers);
      print('Status code: ${response.statusCode}');
      print('============================================');
      //print('Headers: ${response.headers}');
      print('============================================');
      print('Body: ${response.body}');
      print('============================================');
      return _handleResponse(response);
      //return response;
    }

  Future<dynamic> makePostRequest(String router, String body) async {
    resultNotifier.value = RequestLoadInProgress();
    final url = Uri.parse('$urlPrefix/$router');
    final headers = {"Content-type": "application/json",
      "Authorization": "bearer eyJ0eXAiOwiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5MTYzOThhNi0xMjA4LTQ0ODYtYTBjMC0xYTFlZwmJlZGNhMTUiLCJqdGkiOiJjMWE1MDZkMzZhYTc4YmE2NDM0NGY3NzNkYWMyNzIwMTAxNzBmZjdlNTVhZjFiZWZlZWRmZDM5NGRlZDlkYTQzNzVlMjE2ODFhM2I5ZjIzMiIsImlhdCI6MTU5OTY5MjkwMiwibmJmIjoxNTk5NjkyOTAyLCJleHAiOjE2MzEywMjg5MDIsInN1wYiI6IjQiLCJzY29wZXMiOltdfQ.rN1LkEKusr8hQEooQ4PnnTjyavAG0_4br9Ypg_M4aPJ5tuB_8wakeK1DiMHeieoefwWB52jzKsWndxJVd-w19Mj57-H4VymLMFhvj8nhlTBATfhYTc0UZmI0xOo0TFbE45gE-31UKcMCw9zVLqTTZXC2IpJNSdEVEyF2GxfwPPIQRFlOWAXaOemfmMhIuInhj4W8BKSonlGJNVqumV9mXWco6grzs8rBanuVL_phwNDbfEjockBt1HQrhCo-djfJOv66drwnzHt2L-e_PZ-9dWBiawn82VOJstWk-X-RgS1I0jPq-CSYqWvkGg2MFcmzoDoEqlGAyfsbrTJkOSOVf86leN12Lk25iCiqylY5h9dvHRLs3MvV0sUicJvcSWjFcm0QdHDlzvXxTCCcDiV_cakifksePEwY3WuFsRHLIXIM64bT2EuBmF61jQ8F2I1Sf6mxPCpn5VnKi8lB_kCmdjgBM9QTV5it2ABj_7chUq0NAYtPp2AvCEP7oucpHDqmP4sczMkdFnqbHrjZvjuvZCKzIGtQfuNtx2qoK7F5zLDjnyyLZQjBxEvOK4epCmn_HGom2gnMhxoHRTUWdiT8jcjpLEYmYCB9hO2yHdvMNytpKfaL6LE30xc-BaAbklg7Sc-gkBiVJOYHpwV7t4Freij1Rj4w-nR6NycFZ7MUf6D40rx4"};
    //final json = '{"title": "Hello", "body": "body text", "userId": 1}';
    final response = await post(url, headers: headers, body: body);
    /*final response = await Future.wait([
      post(url, headers: headers, body: body)
    ]);*/
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