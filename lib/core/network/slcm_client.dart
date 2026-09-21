import 'package:dio/dio.dart';

/// Called when the server responds with a 302 (session expired).
/// Should perform a fresh login and return the new cookie, or null.
typedef SessionRefreshCallback = Future<String?> Function();

/// Single HTTP client for all SLCM traffic.
///
/// Replaces the scattered `headers` map + `get`/`post` helpers in
/// `lib/utils/util.dart`: default browser-like headers (including
/// `Sec-Fetch-Site`/`Referer`, which SLCM requires) and the session
/// cookie are applied automatically, so call sites just do
/// `slcm.post(Urls.attendance, body: {...})`.
class SlcmClient {
  static const String baseUrl = 'https://mujslcm.jaipur.manipal.edu';

  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Sec-Fetch-Site': 'same-origin',
    'Referer': baseUrl,
  };

  final Dio dio;

  /// Current session cookie. Kept in sync by [SessionStore].
  String? cookie;

  /// Wired up at startup (see `AuthRepository.bindSessionRefresh`).
  /// Kept as a callback (instead of a direct import) to avoid a
  /// network <-> auth import cycle.
  SessionRefreshCallback? onSessionExpired;

  SlcmClient({Dio? dio, this.cookie, this.onSessionExpired})
      : dio = dio ?? Dio();

  Map<String, String> get _headers => {
        ...defaultHeaders,
        if (cookie != null && cookie!.isNotEmpty) 'Cookie': cookie!,
      };

  Future<Response> get(String url, {Map<String, String>? headers}) async {
    final response = await dio.get(
      url,
      options: Options(
        headers: {..._headers, ...?headers},
        validateStatus: (status) => status! < 400,
      ),
    );
    await _refreshIfExpired(response);
    return response;
  }

  Future<Response> post(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    final response = await dio.post(
      url,
      data: body,
      options: Options(
        headers: {..._headers, ...?headers},
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (status) => status! < 400,
      ),
    );
    await _refreshIfExpired(response);
    return response;
  }

  Future<void> _refreshIfExpired(Response response) async {
    if (response.statusCode == 302 && onSessionExpired != null) {
      final fresh = await onSessionExpired!();
      if (fresh != null && fresh.isNotEmpty) {
        cookie = fresh;
      }
    }
  }
}

/// Shared instance used across the app.
final slcm = SlcmClient();
