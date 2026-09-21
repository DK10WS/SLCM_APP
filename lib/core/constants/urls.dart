import '../network/slcm_client.dart';

/// All backend endpoints. Import from here; `lib/pages/redirects.dart`
/// re-exports this file for backwards compatibility during migration.
class Urls {
  static const String login = SlcmClient.baseUrl;
  static const String attendance =
      '${SlcmClient.baseUrl}/Student/Academic/GetAttendanceSummaryList';
  static const String grades =
      '${SlcmClient.baseUrl}/Student/Academic/GetGradesForFaculty';
  static const String marks =
      '${SlcmClient.baseUrl}/Student/Academic/GetInternalMarkForFaculty';
  static const String timeTableWeek =
      '${SlcmClient.baseUrl}/Student/Academic/GetStudentCalenderEventList';
  static const String timeTableEvent =
      '${SlcmClient.baseUrl}/Student/Academic/GetEventDetailStudent';
  static const String information =
      '${SlcmClient.baseUrl}/Employee/EmployeeDirectory/IndexStudent';
  static const String cgpa =
      '${SlcmClient.baseUrl}/Student/Academic/GetCGPAGPAForFaculty';
  static const String changePassword =
      '${SlcmClient.baseUrl}/Home/ChangePassword';

  // Parents (OTP) login.
  static const String otpValidate = '${SlcmClient.baseUrl}/Home/OnValidate';
  static const String otpIndex = '${SlcmClient.baseUrl}/Home/IndexOTP';
  static const String home = '${SlcmClient.baseUrl}/Home/Dashboard';
  static const String onExpire = '${SlcmClient.baseUrl}/Home/OnExpire';
  static const String resendOtp = '${SlcmClient.baseUrl}/Home/ResendOTP';

  // Update check.
  static const String releases =
      'https://api.github.com/repos/DK10WS/SLCM_APP/releases/latest';
  static const String releasesPage =
      'https://github.com/DK10WS/SLCM_APP/releases/';
}
