from pydantic import BaseModel
from typing import Optional

class ShippingInfo(BaseModel):

    #   {
    #         "name": "tdst",
    #         "address_line_1": "tdstds",
    #         "address_line_2": "tdstds",
    #         "city": "tdst",
    #         "state": "stdts",
    #         "zip_code": "sdtt",
    #         "country": "United States"
    #     },

    name: str
    address_line_1: str
    address_line_2: str | None
    city: str
    state: str
    zip_code: str
    country: str