from pydantic import BaseModel


class RegisterCredentials(BaseModel):
    email: str
    password: str
    password_confirm: str