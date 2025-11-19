class SessionManager {
  static String? rf;
  static String? asp;
  static bool loggedOut = false;

  static void setSession(String cookie, String net) {
    asp = net;
    rf = cookie;
    loggedOut = false;
  }

  static void clearSession() {
    rf = null;
    loggedOut = true;
  }

  static bool isLoggedIn() {
    return rf != null && !loggedOut;
  }
}
