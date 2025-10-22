from pydantic import BaseModel


class EditedBid(BaseModel):
    bid_id: str
    new_bid_amount: float
    fee_structure_id: int