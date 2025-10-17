from pydantic import BaseModel, EmailStr
from typing import Optional


class UserCreate(BaseModel):
    email: EmailStr
    password: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None


class UserRead(BaseModel):
    uuid: str
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    class Config:
        orm_mode = True

