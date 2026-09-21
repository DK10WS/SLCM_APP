import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';
import 'package:mujslcm/core/session/session_store.dart';

/// All authentication network calls in one place.
///
/// Consolidates the student-login flow previously duplicated in
/// `lib/utils/login.dart` and `lib/pages/login.dart`, plus the
/// change-password flow from `lib/pages/change_password.dart`.
///
/// UI/navigation stays in the pages; this class only talks HTTP and
/// returns cookies (empty string on failure, matching the old convention).
class AuthRepository {
  static String extractSessionId(String cookie) {
    final parts = cookie.split(';');
    return parts.isNotEmpty ? parts[0].trim() : '';
  }

  static String _cleanCookies(List<String>? cookies) {
    if (cookies == null) return '';
    return cookies.map(extractSessionId).join(';');
  }

  /// Student login. Returns the combined session cookie, or `""` on failure.
  static Future<String> loginStudent(String username, String password) async {
    final result = await loginStudentFull(username, password);
    return result.cookies;
  }

  /// Student login that also surfaces the 302 redirect target, so callers
  /// can detect the forced-change-password flow.
  static Future<({String cookies, String? location})> loginStudentFull(
    String username,
    String password,
  ) async {
    final response = await slcm.get(Urls.login);
    if (response.statusCode != 200) return (cookies: '', location: null);

    final document = parse(response.data);
    final token = document
        .querySelector('input[name="__RequestVerificationToken"]')
        ?.attributes['value'];
    final cookies = response.headers['set-cookie'];
    if (token == null || cookies == null) {
      return (cookies: '', location: null);
    }

    final cleanedCookies = _cleanCookies(cookies);

    // NOTE: `followRedirects: false` is deliberate — the raw 302 status +
    // `location` header are the login result signal (same as the old
    // `dio.post(validateStatus: <500)` call sites, which relied on seeing
    // the 302 instead of a followed 200).
    final loginResponse = await slcm.dio.post(
      Urls.login,
      data: {
        '__RequestVerificationToken': token,
        'EmailFor': '@muj.manipal.edu',
        'LoginFor': '2',
        'UserName': username,
        'Password': password,
      },
      options: Options(
        headers: {...SlcmClient.defaultHeaders, 'Cookie': cleanedCookies},
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (loginResponse.statusCode != 302) {
      return (cookies: '', location: null);
    }

    final apiCookies = _cleanCookies(
      loginResponse.headers.map['set-cookie'],
    );
    return (
      cookies: cleanedCookies + (apiCookies.isNotEmpty ? '; $apiCookies' : ''),
      location: loginResponse.headers.value('location'),
    );
  }

  /// Parents-login step 1 (request OTP). Returns the intermediate session
  /// cookie, or `""` on failure.
  static Future<String> loginParent(String username) async {
    final response = await slcm.get(Urls.login);
    if (response.statusCode != 200) return '';

    final document = parse(response.data);
    final token = document
        .querySelector('input[name="__RequestVerificationToken"]')
        ?.attributes['value'];
    final cookies = response.headers['set-cookie'];
    if (token == null || cookies == null) return '';

    final cleanedCookies = _cleanCookies(cookies);

    final loginResponse = await slcm.dio.post(
      Urls.login,
      data: {
        '__RequestVerificationToken': token,
        'EmailFor': '',
        'LoginFor': '3',
        'UserName': '$username@muj.manipal.edu',
        'Password': '',
      },
      options: Options(
        headers: {...SlcmClient.defaultHeaders, 'Cookie': cleanedCookies},
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (loginResponse.statusCode != 302) return '';

    final apiCookies = _cleanCookies(
      loginResponse.headers.map['set-cookie'],
    );
    return cleanedCookies + (apiCookies.isNotEmpty ? '; $apiCookies' : '');
  }

  /// Change password for the session identified by [cookies].
  ///
  /// Kept on `package:http` (like the original page code): unlike dio it
  /// surfaces the raw 302 + `location` header, which is the success signal.
  static Future<bool> changePassword(
    String cookies,
    String newPassword,
  ) async {
    final session = http.Client();
    try {
      final headers = {...SlcmClient.defaultHeaders, 'Cookie': cookies};

      final response = await session.get(
        Uri.parse(Urls.changePassword),
        headers: headers,
      );
      if (response.statusCode != 200) return false;

      final document = parse(response.body);
      final token = document
          .querySelector('input[name="__RequestVerificationToken"]')
          ?.attributes['value'];
      if (token == null) return false;

      final result = await session.post(
        Uri.parse(Urls.changePassword),
        headers: headers,
        body: {
          '__RequestVerificationToken': token,
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
      );
      return result.statusCode == 302 && result.headers['location'] == '/';
    } finally {
      session.close();
    }
  }

  /// Registers the 302 -> re-login handler used by [SlcmClient].
  /// Call once at startup. Preserves the old `util.dart` behavior:
  /// saved credentials are retried silently and the store is updated.
  static void bindSessionRefresh() {
    slcm.onSessionExpired = () async {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final password = prefs.getString('password') ?? '';
      if (username.isEmpty || password.isEmpty) return null;

      final cookie = await loginStudent(username, password);
      if (cookie.isEmpty) return null;
      SessionStore.set(cookie);
      return cookie;
    };
  }
}
