String baseURL = "https://betterslcm.whyredfire.tech/api";
String loginURL = baseURL + "/login";
String infomationURL = baseURL + "/info";
String cgpaURL = baseURL + "/cgpa";
String TimetableWeek = baseURL + "/timetable_week?dated=";
String TimetableEvent = baseURL + "/timetable?eventid=";
String GradesURL = baseURL + "/grades?semester=";
String MarksURL = baseURL + "/internal_marks?semester=";
String AttendanceURL = baseURL + "/attendance";

String SendOTP = baseURL + "/login/parents/otp";
String HomeURL = baseURL + "/login/parents";
String OnExpireURL = baseURL + "/login/parents/expireotp";
String ResendOTPUrl = baseURL + "/Home/ResendOTP";

final Map<String, String> header = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
  "Content-Type": "application/json",
};
