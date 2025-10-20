from pydantic import BaseModel

from app.pydantic_models.shipping_info import ShippingInfo


class NewOrder(BaseModel):
    # {
    #     "buyer_id": "1f23aae9-ad06-11f0-9b7b-60452e6df230",
    #     "shipping_info": {
    #         "name": "tdst",
    #         "address_line_1": "tdstds",
    #         "address_line_2": "tdstds",
    #         "city": "tdst",
    #         "state": "stdts",
    #         "zip_code": "sdtt",
    #         "country": "United States"
    #     },
    #     "listing_id": 3,
    #     "transaction_fee": 10,
    #     "payment_method": "credit_card"
    # }

    buyer_id: str
    shipping_info: ShippingInfo
    listing_id: int
    transaction_fee: float
    payment_method: str