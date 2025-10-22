from pydantic import BaseModel


class NewBidInfo(BaseModel):
    user_id: str
    product_id: str
    size: str
    product_condition: str
    bid_amount: float
    fee_structure_id: int
    payment_origin: str