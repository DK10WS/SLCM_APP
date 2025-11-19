class SessionManager {
  static Map<String, dynamic> sessionCookie = {};
  static bool loggedOut = false;

  static void setSession(Map<String, dynamic> cookie) {
    sessionCookie = cookie;
    loggedOut = false;
  }

  static void clearSession() {
    sessionCookie = {};
    loggedOut = true;
  }

  static bool isLoggedIn() {
    return sessionCookie != {} && !loggedOut;
  }
}
