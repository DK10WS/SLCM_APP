import requests
from bs4 import BeautifulSoup
from fastapi import APIRouter, HTTPException, Request, Response

from .schemas import Credentials, loginCookies, parentLogin

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/112.0",
}

API_REF = {
    "login": "https://mujslcm.jaipur.manipal.edu",
    "otp_index": "/Home/IndexOTP",
    "otp_validate": "/Home/OnValidate",
    "otp_expire": "/Home/OnExpire",
    "otp_resend": "/Home/ResendOTP",
    "details": "/Employee/EmployeeDirectory/IndexStudent",
    "info": "/Employee/EmployeeDirectory/IndexStudent",
    "timetable": "/Student/Academic/GetEventDetailStudent",
    "timetable_week": "/Student/Academic/GetStudentCalenderEventList",
    "attendance": "/Student/Academic/GetAttendanceSummaryList",
    "cgpa": "/Student/Academic/GetCGPAGPAForFaculty",
    "grades": "/Student/Academic/GetGradesForFaculty",
    "internal_marks": "/Student/Academic/GetInternalMarkForFaculty",
}


def make_request(login_cookies, endpoint, request, data=None):
    try:
        login_cookies_array = login_cookies.split(";")

        res = requests.post(
            url=API_REF["login"] + API_REF[endpoint],
            data=data,
            headers=HEADERS,
            cookies={
                "__RequestVerificationToken": login_cookies_array[0],
                "ASP.NET_SessionId": login_cookies_array[1],
            },
        )

        if endpoint == "otp_index" or endpoint == "otp_validate":
            return res
        return res.json()
    except requests.exceptions.JSONDecodeError:
        raise HTTPException(status_code=401, detail={"message": "unauthorized"})


def _get_token():
    res = requests.get(
        API_REF["login"], headers=HEADERS, allow_redirects=False, timeout=5
    )
    soup = BeautifulSoup(res.content, "html.parser")

    token = soup.find("input", {"name": "__RequestVerificationToken"})["value"]
    cookies = res.headers.get("Set-Cookie").split(";")[0]
    cookie = cookies.split("=")[1]

    return token, cookie


def _get_otp_token(cook):
    login_cookies_array = cook.split(";")
    cookies = {
        "__RequestVerificationToken": login_cookies_array[0],
        "ASP.NET_SessionId": login_cookies_array[1],
    }

    res = requests.get(
        API_REF["login"] + API_REF["otp_index"], headers=HEADERS, cookies=cookies
    )

    soup = BeautifulSoup(res.content, "html.parser")
    token = soup.find("input", {"name": "__RequestVerificationToken"})["value"]

    return token


router = APIRouter()


@router.post("/login")
async def login(creds: Credentials, response: Response):
    token, cookie = _get_token()

    cookies = {"__RequestVerificationToken": cookie}
    payload = {
        "__RequestVerificationToken": token,
        "EmailFor": "@muj.manipal.edu",
        "LoginFor": "2",
        "UserName": creds.username,
        "Password": creds.password,
    }

    res = requests.post(
        url=API_REF["login"],
        data=payload,
        headers=HEADERS,
        cookies=cookies,
        allow_redirects=False,
    )

    if not res.headers.get("Set-Cookie"):
        raise HTTPException(status_code=401, detail={"message": "invalid credentials"})

    session_id = res.headers.get("Set-Cookie").split(";")[0].split("=")[1]

    response.set_cookie(
        key="__RequestVerificationToken", value=cookie, expires="Session"
    )
    response.set_cookie(key="ASP.NET_SessionId", value=session_id)

    details_page = requests.get(
        url=API_REF["login"] + API_REF["details"],
        headers=HEADERS,
        cookies={
            "__RequestVerificationToken": cookie,
            "ASP.NET_SessionId": session_id,
        },
    ).content

    details_soup = BeautifulSoup(details_page, "html.parser")
    user_card_name_element = details_soup.find(class_="kt-user-card__name").text

    return {
        "message": "user logged in",
        "name": user_card_name_element,
        "login_cookies": f"{cookie};{session_id}",
    }


@router.post("/login/parents")
async def login(creds: Credentials, response: Response):
    token, cookie = _get_token()

    cookies = {"__RequestVerificationToken": cookie}
    payload = {
        "__RequestVerificationToken": token,
        "EmailFor": "",
        "LoginFor": "3",
        "UserName": creds.username,
        "Password": "",
    }

    res = requests.post(
        url=API_REF["login"],
        data=payload,
        headers=HEADERS,
        cookies=cookies,
        allow_redirects=False,
    )

    student_name = creds.username.split(".")[0]
    session_id = res.headers.get("Set-Cookie").split(";")[0].split("=")[1]

    response.set_cookie(
        key="__RequestVerificationToken", value=cookie, expires="Session"
    )
    response.set_cookie(key="ASP.NET_SessionId", value=session_id)

    return {
        "message": "OTP sent successfully",
        "name": student_name,
        "login_cookies": f"{cookie};{session_id}",
    }


@router.post("/login/parents/otp")
async def login_otp(login: parentLogin, request: Request):
    token = _get_otp_token(login.cookies)
    payload = {"OTP": login.otp}

    make_request(login.cookies, "otp_validate", request=request, data=payload)

    payload = {"__RequestVerificationToken": token, "OTPPassword": login.otp}

    login_cookies_array = login.cookies.split(";")

    res = requests.post(
        url=API_REF["login"] + API_REF["otp_index"],
        data=payload,
        headers=HEADERS,
        cookies={
            "__RequestVerificationToken": login_cookies_array[0],
            "ASP.NET_SessionId": login_cookies_array[1],
        },
        allow_redirects=False,
    )

    if res.status_code == 302:
        return {"message": "logged in sucessfully"}

    raise HTTPException(status_code=401, detail={"message": "unauthorized"})


@router.post("/login/parents/expireotp")
async def expire_otp(cookies: loginCookies, request: Request):
    res = make_request(
        cookies.login_cookies, "otp_expire", request=request, data={"Flag": "--"}
    )

    if res.status_code == 200:
        return {"message": "expired otp successfully"}

    raise HTTPException(status_code=401, detail={"message": "something went wrong"})


@router.post("/login/parents/resendotp")
async def resend_otp(cookies: loginCookies, request: Request):
    res = make_request(
        cookies.login_cookies, "otp_resend", request=request, data={"QnsStr": "--"}
    )

    if res.status_code == 200:
        return {"message": "resent otp"}

    raise HTTPException(status_code=401, detail={"message": "something went wrong"})


@router.post("/info")
async def info(cook: loginCookies, request: Request):
    login_cookies = cook.login_cookies.split(";")

    info_page = requests.get(
        url=API_REF["login"] + API_REF["info"],
        headers=HEADERS,
        cookies={
            "__RequestVerificationToken": login_cookies[0],
            "ASP.NET_SessionId": login_cookies[1],
        },
    ).content

    info_soup = BeautifulSoup(info_page, "html.parser")

    def extract_value(name):
        input_tag = info_soup.find("input", {"name": name})
        return input_tag["value"] if input_tag else "Not found"

    registration_no = extract_value("RegistrationNo")
    name = extract_value("EmpName")
    program = extract_value("CourseName")
    semester = extract_value("Semester")
    section = extract_value("Section")
    batch = extract_value("Batch")
    gender = extract_value("Gender")
    mobile_no = extract_value("MobileNumber")

    # Extract Class Coordinator details
    class_coordinator = "Not found"
    class_coordinator_mail = "Not found"
    student_mentor = "Not found"

    rows = info_soup.find_all("tr")
    for row in rows:
        cells = row.find_all("td")
        if len(cells) > 1 and cells[1].text.strip() == "Class Coordinator":
            class_coordinator = cells[2].text.strip() if len(cells) > 2 else "Not found"
            class_coordinator_mail = (
                cells[3].text.strip() if len(cells) > 3 else "Not found"
            )
        elif len(cells) > 1 and cells[1].text.strip() == "Student Mentor":
            student_mentor = cells[2].text.strip() if len(cells) > 2 else "Not found"

    return {
        "registration_no": registration_no,
        "name": name,
        "program": program,
        "semester": semester,
        "section": section,
        "batch": batch,
        "gender": gender,
        "mobile_no": mobile_no,
        "class_coordinator": class_coordinator,
        "class_coordinator_mail": class_coordinator_mail,
        "student_mentor": student_mentor,
    }


@router.post("/timetable_week")
async def timetable_week(cook: loginCookies, request: Request, dated: str):
    return make_request(
        cook.login_cookies,
        "timetable_week",
        request=request,
        data={
            "Year": "",
            "Month": "",
            "Type": "agendaWeek",
            "Dated": dated,
            "PreNext": "2",
        },
    )


@router.post("/timetable")
async def timetable(cook: loginCookies, request: Request, eventid: str):
    return make_request(
        cook.login_cookies, "timetable", request=request, data={"EventID": eventid}
    )


@router.post("/attendance")
async def attendance(cook: loginCookies, request: Request):
    return make_request(
        cook.login_cookies,
        "attendance",
        request=request,
        data={"StudentCode": ""},
    )


@router.post("/cgpa")
async def cgpa(cook: loginCookies, request: Request):
    return make_request(
        cook.login_cookies,
        "cgpa",
        request=request,
        data={"Enrollment": "", "AcademicYear": "", "ProgramCode": ""},
    )


@router.post("/grades")
async def grades(cook: loginCookies, request: Request, semester: str):
    return make_request(
        cook.login_cookies,
        "grades",
        request=request,
        data={"Enrollment": "", "Semester": semester},
    )


@router.post("/internal_marks")
async def internal_marks(cook: loginCookies, request: Request, semester: str):
    return make_request(
        cook.login_cookies,
        "internal_marks",
        request=request,
        data={"Enrollment": "", "Semester": semester},
    )
