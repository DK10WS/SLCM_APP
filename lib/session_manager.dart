class SessionManager {
  static String? sessionCookie;

  static void setSession(String cookie) {
    sessionCookie = cookie;
  }

  static void clearSession() {
    sessionCookie = null;
  }

  static bool isLoggedIn() {
    return sessionCookie != null;
  }
}
