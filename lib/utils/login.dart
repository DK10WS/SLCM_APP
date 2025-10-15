import 'package:mujslcm/utils/util.dart';
import "package:mujslcm/pages/redirects.dart";
import 'package:html/parser.dart' show parse;

String extractSessionId(String cookie) {
  final parts = cookie.split(';');
  return parts.isNotEmpty ? parts[0].trim() : '';
}

Future<String> login(String username, String password) async {
  var baseurl = loginURL;

  final response = await get(
    baseurl,
    headers,
  );

  if (response.statusCode != 200) {
    print("Failed to fetch login page.");
    return "";
  }

  final document = parse(response.data);
  final tokenElement =
      document.querySelector('input[name="__RequestVerificationToken"]');
  final token = tokenElement?.attributes['value'];
  final cookies = response.headers['set-cookie'];

  if (token == null || cookies == null) {
    print("Token or session cookies missing.");
    return "";
  }

  final cleanedCookies =
      cookies.map((cookie) => extractSessionId(cookie)).join(';');

  final payload = {
    "__RequestVerificationToken": token,
    "EmailFor": "@muj.manipal.edu",
    "LoginFor": "2",
    "UserName": username,
    "Password": password,
  };

  final headersForLogin = {
    ...headers,
    'Cookie': cleanedCookies,
  };

  final loginResponse = await post(
    baseurl,
    headersForLogin,
    payload,
  );

  var apiCookies = loginResponse.headers.map['set-cookie'];
  final cleanedAPI = apiCookies != null
      ? apiCookies.map((cookie) => extractSessionId(cookie)).join(';')
      : '';

  if (loginResponse.statusCode == 302) {
    final newCookies =
        cleanedCookies + (cleanedAPI.isNotEmpty ? '; $cleanedAPI' : '');
    return newCookies;
  }
  return "";
}
