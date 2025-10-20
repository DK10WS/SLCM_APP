from pydantic import BaseModel


class Credentials(BaseModel):
    username: str
    password: str | str = ""


class loginCookies(BaseModel):
    login_cookies: str


class parentLogin(BaseModel):
    cookies: str
    otp: str
