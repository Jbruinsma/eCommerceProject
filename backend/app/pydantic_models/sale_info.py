from pydantic import BaseModel


class SaleInfo(BaseModel):
    listing_type: str
    brand_id: int
    product_id: int
    size_id: int
    item_condition: str
    price: int
    fee_id: int
    target_bid_id: str