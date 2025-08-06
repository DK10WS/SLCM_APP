class SessionManager {
  static String? sessionCookie;
  static bool loggedOut = false;

  static void setSession(String cookie) {
    sessionCookie = cookie;
    loggedOut = false;
  }

  static void clearSession() {
    sessionCookie = null;
    loggedOut = true;
  }

  static bool isLoggedIn() {
    return sessionCookie != null && !loggedOut;
  }
}
