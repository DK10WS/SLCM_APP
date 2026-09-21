import '../network/slcm_client.dart';

/// Single source of truth for the SLCM session cookie.
///
/// Replaces `SessionManager`: same static API (so existing call sites
/// keep compiling), but every write also syncs [slcm.cookie] so the
/// network layer always sends the current session automatically.
class SessionStore {
  static String? get cookie => slcm.cookie;
  static bool loggedOut = false;

  static void set(String cookie) {
    slcm.cookie = cookie;
    loggedOut = false;
  }

  static void clear() {
    slcm.cookie = null;
    loggedOut = true;
  }

  static bool isLoggedIn() => slcm.cookie != null && !loggedOut;
}
