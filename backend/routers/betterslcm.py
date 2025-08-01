from bs4 import BeautifulSoup
from fastapi import APIRouter, Response, Request, HTTPException
import requests

from schemas import UserCredentials, ParentsLogin

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


def cookies_template(token_cookie, session_cookie):
    return {
        "__RequestVerificationToken": token_cookie,
        "ASP.NET_SessionId": session_cookie,
    }


def _make_request(endpoint, request, data=None, redirect=True):
    try:
        res = requests.post(
            url=API_REF["login"] + API_REF[endpoint],
            data=data,
            headers=HEADERS,
            cookies=cookies_template(
                request.cookies.get("__RequestVerificationToken"),
                request.cookies.get("ASP.NET_SessionId"),
            ),
            allow_redirects=redirect,
        )

        # these endpoints donot return json response
        if endpoint in ["otp_index", "otp_validate", "otp_expire", "otp_resend"]:
            return res.status_code, res.content  # usually a yes or no

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
    token_cookie = cookies.split("=")[1]

    return token, token_cookie


app = APIRouter()


@app.post("/login")
async def login(credentials: UserCredentials, response: Response):

    token, token_cookie = _get_token()
    cookies = {"__RequestVerificationToken": token_cookie}
    payload = {
        "__RequestVerificationToken": token,
        "EmailFor": "@muj.manipal.edu",
        "LoginFor": "2",
        "UserName": credentials.username,
        "Password": credentials.password,
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

    session_cookie = res.headers.get("Set-Cookie").split(";")[0].split("=")[1]

    response.set_cookie(
        key="__RequestVerificationToken", value=token_cookie, expires="Session"
    )
    response.set_cookie(key="ASP.NET_SessionId", value=session_cookie)

    details_page = requests.get(
        url=API_REF["login"] + API_REF["details"],
        headers=HEADERS,
        cookies=cookies_template(token_cookie, session_cookie),
    ).content

    details_soup = BeautifulSoup(details_page, "html.parser")
    student_name = details_soup.find(class_="kt-user-card__name").text

    return {
        "message": "user logged in",
        "name": student_name.title(),
    }


@app.post("/login/parents")
async def login(credentials: UserCredentials, response: Response):
    token, token_cookie = _get_token()

    cookies = {"__RequestVerificationToken": token_cookie}
    payload = {
        "__RequestVerificationToken": token,
        "EmailFor": "",
        "LoginFor": "3",
        "UserName": f"{credentials.username}@muj.manipal.edu",
        "Password": "",
    }

    res = requests.post(
        url=API_REF["login"],
        data=payload,
        headers=HEADERS,
        cookies=cookies,
        allow_redirects=False,
    )

    student_name = credentials.username.split(".")[0]
    session_id = res.headers.get("Set-Cookie").split(";")[0].split("=")[1]

    response.set_cookie(
        key="__RequestVerificationToken", value=token_cookie, expires="Session"
    )
    response.set_cookie(key="ASP.NET_SessionId", value=session_id)

    return {
        "message": "OTP sent successfully",
        "name": student_name.title(),
    }


@app.post("/login/parents/otp")
async def login_otp(login: ParentsLogin, request: Request):

    def _get_otp_token(request):
        res = requests.get(
            API_REF["login"] + API_REF["otp_index"],
            headers=HEADERS,
            cookies=cookies_template(
                request.cookies.get("__RequestVerificationToken"),
                request.cookies.get("ASP.NET_SessionId"),
            ),
        )

        soup = BeautifulSoup(res.content, "html.parser")
        token = soup.find("input", {"name": "__RequestVerificationToken"})["value"]

        return token

    # validate otp
    _res_status, _res_content = _make_request(
        endpoint="otp_validate", request=request, data={"OTP": login.otp}
    )

    if _res_status != 200 or _res_content == "No":
        raise HTTPException(
            status_code=401, detail={"message": "OTP validation failed"}
        )

    # send otp
    token = _get_otp_token(request)
    payload = {"__RequestVerificationToken": token, "OTPPassword": login.otp}

    res_status, res_content = _make_request(
        endpoint="otp_index", request=request, data=payload, redirect=False
    )

    if not res_status == 302:
        raise HTTPException(status_code=401, detail={"message": "unauthorized"})

    return {"message": "logged in sucessfully"}


@app.get("/login/parents/otp/resend")
async def resend_otp(request: Request):
    # expire otp
    _res_status, _res_content = _make_request(
        endpoint="otp_expire", request=request, data={"Flag": "--"}
    )
    if _res_status != 200 or _res_content == "No":
        raise HTTPException(
            status_code=500,
            detail={"message": "Something went wrong", "key": "OTP_EXPIRE"},
        )

    # resend otp
    res_status, res_content = _make_request(
        endpoint="otp_resend", request=request, data={"QnsStr": "--"}
    )
    if res_status != 200:
        raise HTTPException(
            status_code=500,
            detail={"message": "Something went wrong", "key": "OTP_RESEND"},
        )

    return {"message": "resent otp"}


@app.get("/info")
async def info(request: Request):
    info_page = requests.get(
        url=API_REF["login"] + API_REF["info"],
        headers=HEADERS,
        cookies=cookies_template(
            request.cookies.get("__RequestVerificationToken"),
            request.cookies.get("ASP.NET_SessionId"),
        ),
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
        "name": name.title(),
        "program": program.title(),
        "semester": semester,
        "section": section,
        "batch": batch.title(),
        "gender": gender,
        "mobile_no": mobile_no,
        "class_coordinator": class_coordinator,
        "class_coordinator_mail": class_coordinator_mail,
        "student_mentor": student_mentor,
    }


@app.get("/timetable_week")
async def timetable_week(request: Request, dated: str):
    return _make_request(
        endpoint="timetable_week",
        request=request,
        data={
            "Year": "",
            "Month": "",
            "Type": "agendaWeek",
            "Dated": dated,
            "PreNext": "2",
        },
    )


@app.get("/timetable")
async def timetable(request: Request, eventid: str):
    return _make_request(
        endpoint="timetable", request=request, data={"EventID": eventid}
    )


@app.get("/attendance")
async def attendance(request: Request):
    return _make_request(
        endpoint="attendance",
        request=request,
        data={"StudentCode": ""},
    )


@app.get("/cgpa")
async def cgpa(request: Request):
    return _make_request(
        endpoint="cgpa",
        request=request,
        data={"Enrollment": "", "AcademicYear": "", "ProgramCode": ""},
    )


@app.get("/grades")
async def grades(request: Request, semester: str):
    return _make_request(
        endpoint="grades",
        request=request,
        data={"Enrollment": "", "Semester": semester},
    )


@app.get("/internal_marks")
async def internal_marks(request: Request, semester: str):
    return _make_request(
        endpoint="internal_marks",
        request=request,
        data={"Enrollment": "", "Semester": semester},
    )
