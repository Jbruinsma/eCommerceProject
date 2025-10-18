from pydantic import BaseModel, EmailStr, ConfigDict
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

    # Pydantic v2: replace `orm_mode` with `from_attributes` via ConfigDict
    model_config = ConfigDict(from_attributes=True)
