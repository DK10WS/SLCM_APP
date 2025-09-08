import 'package:dio/dio.dart';

final headers = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
  "Content-Type": "application/x-www-form-urlencoded",
};

final dio = Dio();
Future<Response> get(String url, Map<String, String> headers) async {
  final response = await dio.get(url,
      options: Options(headers: headers, followRedirects: false));
  return response;
}

Future<Response> post(String url, Map<String, String> postheaders,
    Map<String, String> payload) async {
  final response = dio.post(url,
      data: payload,
      options: Options(
        headers: postheaders,
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (status) => status! < 400,
      ));
  return response;
}
