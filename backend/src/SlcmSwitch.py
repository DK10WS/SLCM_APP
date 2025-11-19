from contextlib import asynccontextmanager
from typing import Any, AsyncGenerator

from bs4 import BeautifulSoup
from httpx import AsyncClient

from .models import SlcmCookies, SlcmCookiesWithName


class SlcmSwitch:
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/112.0"
    base_url = "https://mujslcm.jaipur.manipal.edu"

    # Parent login endpoints
    otp_index_endpoint = "/Home/IndexOTP"
    otp_validate_endpoint = "/Home/OnValidate"
    otp_expire_endpoint = "/Home/OnExpire"
    otp_resend_endpoint = "/Home/ResendOTP"

    # Informational endpoints
    info_endpoint = "/Employee/EmployeeDirectory/IndexStudent"
    timetable_endpoint = "/Student/Academic/GetEventDetailStudent"
    timetable_week_endpoint = "/Student/Academic/GetStudentCalenderEventList"
    attendance_endpoint = "/Student/Academic/GetAttendanceSummaryList"
    cgpa_endpoint = "/Student/Academic/GetCGPAGPAForFaculty"
    grades_endpoint = "/Student/Academic/GetGradesForFaculty"
    internal_marks_endpoint = "/Student/Academic/GetInternalMarkForFaculty"

    @asynccontextmanager
    async def _client(self, *args, **kwargs) -> AsyncGenerator[AsyncClient]:
        client = AsyncClient(
            base_url=self.base_url,
            headers={"User-Agent": self.user_agent},
            timeout=10,
            *args,
            **kwargs,
        )
        try:
            yield client
        finally:
            await client.aclose()

    @staticmethod
    def _get_csrf_token(body: bytes) -> str:
        soup = BeautifulSoup(body, "html.parser")
        token_tag = soup.find("input", {"name": "__RequestVerificationToken"})
        return token_tag["value"]  # type: ignore

    async def _fetch_login_token(self) -> tuple[str, SlcmCookies]:
        async with self._client() as client:
            res = await client.get("/")
            res.raise_for_status()

            csrf_token = self._get_csrf_token(res.content)
            verification_token = res.cookies["__RequestVerificationToken"]

            return csrf_token, SlcmCookies(verification_token=verification_token)

    """Student Endpoints"""

    async def student_login(self, username: str, password: str) -> SlcmCookiesWithName:
        csrf_token, cookies = await self._fetch_login_token()

        async with self._client() as client:
            payload = {
                "__RequestVerificationToken": csrf_token,
                "EmailFor": "@muj.manipal.edu",
                "LoginFor": "2",
                "UserName": username,
                "Password": password,
            }

            res = await client.post(
                "/",
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
                follow_redirects=False,
            )

            return SlcmCookiesWithName(
                verification_token=cookies.verification_token,
                asp_net_id=res.cookies["ASP.NET_SessionId"],
                name=username.split(".")[0].upper(),
            )

    """Parent Endpoints"""

    async def parent_login(self, username: str) -> SlcmCookies:
        token, cookies = await self._fetch_login_token()

        async with self._client() as client:
            payload = {
                "__RequestVerificationToken": token,
                "EmailFor": "",
                "LoginFor": "3",
                "UserName": username,
                "Password": "",
            }

            res = await client.post(
                "/",
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
                follow_redirects=False,
            )

            return SlcmCookies(
                verification_token=cookies.verification_token,
                asp_net_id=res.cookies["ASP.NET_SessionId"],
            )

    async def parent_submit_otp(self, cookies: SlcmCookies, otp: str) -> None:
        async with self._client() as client:
            # Fetch token from OTP page
            token_res = await client.get(
                self.otp_index_endpoint, cookies=cookies.model_dump(by_alias=True)
            )
            token_res.raise_for_status()
            token = self._get_csrf_token(token_res.content)

            # Initial validation request
            validation_res = await client.post(
                self.otp_validate_endpoint,
                data={"OTP": otp},
                cookies=cookies.model_dump(by_alias=True),
            )
            validation_res.raise_for_status()

            # Final submit request
            payload = {"__RequestVerificationToken": token, "OTPPassword": otp}
            res = await client.post(
                self.otp_index_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
                follow_redirects=False,
            )
            res.raise_for_status()

    async def parent_resend_otp(self, cookies: SlcmCookies) -> None:
        async with self._client() as client:
            # Expire existing OTP
            expire_res = await client.post(
                self.otp_expire_endpoint, data={"Flag": "--"}
            )
            expire_res.raise_for_status()

            # Resend OTP
            resend_res = await client.post(
                self.otp_resend_endpoint, data={"QnsStr": "--"}
            )
            resend_res.raise_for_status()

    """Common Endpoints"""

    async def get_student_info(self, cookies: SlcmCookies):
        def extract_value(key: str) -> str:
            input_tag = soup.find("input", {"name": key})
            return input_tag["value"] if input_tag else "Not found"  # type: ignore

        async with self._client() as client:
            res = await client.get(
                self.info_endpoint,
                cookies=cookies.model_dump(by_alias=True),
                follow_redirects=True,
            )
            res.raise_for_status()

            soup = BeautifulSoup(res.content, "html.parser")

            # Extract student details
            registration_no = extract_value("RegistrationNo")
            name = extract_value("EmpName")
            program = extract_value("CourseName")
            semester = extract_value("Semester")
            section = extract_value("Section")
            batch = extract_value("Batch")
            gender = extract_value("Gender")
            mobile_no = extract_value("MobileNumber")

            # Extract Class Coordinator details
            class_coordinator = None
            class_coordinator_mail = None
            student_mentor = None

            rows = soup.find_all("tr")
            for row in rows:
                cells = row.find_all("td")  # type: ignore
                if len(cells) > 1 and cells[1].text.strip() == "Class Coordinator":
                    class_coordinator = (
                        cells[2].text.strip() if len(cells) > 2 else "Not found"
                    )
                    class_coordinator_mail = (
                        cells[3].text.strip() if len(cells) > 3 else "Not found"
                    )
                elif len(cells) > 1 and cells[1].text.strip() == "Student Mentor":
                    student_mentor = (
                        cells[2].text.strip() if len(cells) > 2 else "Not found"
                    )

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

    async def get_attendance(self, cookies: SlcmCookies) -> dict[str, Any]:
        async with self._client() as client:
            payload = {"StudentCode": ""}
            res = await client.post(
                self.attendance_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
            )
            res.raise_for_status()
            return res.json()

    async def get_cgpa(self, cookies: SlcmCookies) -> dict[str, Any]:
        async with self._client() as client:
            payload = {"Enrollment": "", "AcademicYear": "", "ProgramCode": ""}
            res = await client.post(
                self.cgpa_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
            )
            res.raise_for_status()
            return res.json()

    async def get_grade(self, cookies: SlcmCookies, semester: str) -> dict[str, Any]:
        async with self._client() as client:
            payload = {"Enrollment": "", "Semester": semester}
            res = await client.post(
                self.grades_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
            )
            res.raise_for_status()
            return res.json()

    async def get_internal_marks(
        self, cookies: SlcmCookies, semester: str
    ) -> dict[str, Any]:
        async with self._client() as client:
            payload = {"Enrollment": "", "Semester": semester}
            res = await client.post(
                self.internal_marks_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
            )
            res.raise_for_status()
            return res.json()

    async def get_timetable(
        self, cookies: SlcmCookies, event_id: str
    ) -> dict[str, Any]:
        async with self._client() as client:
            payload = {"EventID": event_id}
            res = await client.post(
                self.timetable_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
            )
            res.raise_for_status()

            return res.json()

    async def get_timetable_week(
        self, cookies: SlcmCookies, date: str
    ) -> dict[str, Any]:
        async with self._client() as client:
            payload = {
                "Year": "",
                "Month": "",
                "Type": "agendaWeek",
                "Dated": date,
                "PreNext": "2",
            }
            res = await client.post(
                self.timetable_week_endpoint,
                data=payload,
                cookies=cookies.model_dump(by_alias=True),
            )
            res.raise_for_status()

            return res.json()
