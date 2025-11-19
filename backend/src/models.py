from typing import Optional

from pydantic import BaseModel, Field


class SlcmCookies(BaseModel):
    verification_token: str = Field(
        ...,
        alias="__RequestVerificationToken",
        description="The Request verification token",
    )
    asp_net_id: Optional[str] = Field(
        None, alias="ASP.NET_SessionId", description="The ASP.NET session id"
    )

    class Config:
        populate_by_name = True


class SlcmCookiesWithName(SlcmCookies):
    name: str = Field(..., description="The name of the student")


class ParentLogin(BaseModel):
    username: str = Field(..., description="The username of the student")


class StudentLogin(ParentLogin):
    password: str = Field(..., description="The corresponding password")


class ParentLoginOTP(SlcmCookies):
    otp: str = Field(..., description="The OTP for the login")
