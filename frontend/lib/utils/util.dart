import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mujslcm/session_manager.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

final headers = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
  'Content-Type': 'application/json',
};

final Map<String, String> body = {...SessionManager.sessionCookie};

final dio = Dio();
Future<Response> get(String url, Map<String, String> headers) async {
  final response = await dio.get(url,
      options: Options(
        headers: headers,
        validateStatus: (status) => status! < 400,
      ));

  return response;
}

Future<Response> post(String url, Map<String, String> postheaders,
    Map<String, String> payload) async {
  final response = await dio.post(url,
      data: payload,
      options: Options(
        headers: postheaders,
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 400,
      ));
  return response;
}
