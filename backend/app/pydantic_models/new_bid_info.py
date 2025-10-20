from pydantic import BaseModel


class NewBidInfo(BaseModel):
    user_id: str
    product_id: str
    size: str
    product_condition: str
    bid_amount: float
    transaction_fee: float
    total_amount: float
    bid_status: str