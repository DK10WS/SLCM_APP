from fastapi import APIRouter, HTTPException

from .models import IncorrectPassword, ParentLogin, SlcmCookies, StudentLogin
from .SlcmSwitch import SlcmSwitch

router = APIRouter()
slcm = SlcmSwitch()


@router.post("/login/student")
async def student_login(login: StudentLogin) -> dict[str, str]:
    try:
        cookies = await slcm.student_login(login.username, login.password)
        return cookies.model_dump(by_alias=True)
    except IncorrectPassword:
        raise HTTPException(status_code=401, detail="Incorrect Password")


@router.post("/login/parent")
async def parent_login(login: ParentLogin) -> dict[str, str]:
    cookies = await slcm.parent_login(login.username)
    return cookies.model_dump(by_alias=True)


@router.post("/login/parent/otp")
async def parent_login_otp(cookies: SlcmCookies, otp: str):
    await slcm.parent_submit_otp(cookies, otp)
    return {"status": "ok"}


@router.post("/login/parent/resend-otp")
async def parent_resend_otp(cookies: SlcmCookies):
    await slcm.parent_resend_otp(cookies)
    return {"status": "ok"}


@router.post("/info")
async def info(cookies: SlcmCookies):
    info = await slcm.get_student_info(cookies)
    return info


@router.post("/attendance")
async def attendance(cookies: SlcmCookies):
    attendance = await slcm.get_attendance(cookies)
    return attendance


@router.post("/cgpa")
async def cgpa(cookies: SlcmCookies):
    cgpa = await slcm.get_cgpa(cookies)
    return cgpa


@router.post("/grade")
async def grade(cookies: SlcmCookies, semester: str):
    grade = await slcm.get_grade(cookies, semester)
    return grade


@router.post("/internal-marks")
async def internal_marks(cookies: SlcmCookies, semester: str):
    internal_marks = await slcm.get_internal_marks(cookies, semester)
    return internal_marks


@router.post("/timetable")
async def timetable(cookies: SlcmCookies, event_id: str):
    time_table = await slcm.get_timetable(cookies, event_id)
    return time_table


@router.post("/timetable-week")
async def timetable_week(cookies: SlcmCookies, date: str):
    timetable_week = await slcm.get_timetable_week(cookies, date)
    return timetable_week
