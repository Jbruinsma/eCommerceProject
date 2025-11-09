from __future__ import annotations

from pydantic import BaseModel

from ..pydantic_models.address import Address


class NewBidInfo(BaseModel):
    user_id: str
    product_id: str
    size: str
    product_condition: str
    bid_amount: float
    fee_structure_id: int
    payment_origin: str
    shipping_info: Address