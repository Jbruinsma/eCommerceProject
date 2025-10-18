from typing import Optional
from pydantic import BaseModel


class UpdatedUser(BaseModel):
    uuid: Optional[str] = None
    email: Optional[str] = None
    password: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    location: Optional[str] = None
    birth_date: Optional[str] = None
    role: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
