from pydantic import BaseModel


class Address(BaseModel):
    name: str
    address_line_1: str
    address_line_2: str | None
    city: str
    state: str
    zip_code: str
    country: str