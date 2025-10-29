from pydantic import BaseModel

from ..pydantic_models.shipping_info import ShippingInfo


class NewOrder(BaseModel):
    buyer_id: str
    shipping_info: ShippingInfo
    listing_id: int
    purchase_price: float
    transaction_structure_fee_id: int
    payment_method: str