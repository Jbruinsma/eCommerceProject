from pydantic import BaseModel


class NewListingInfo(BaseModel):
    listing_type: str
    brand_id: int
    product_id: int
    size_id: int
    item_condition: str
    price: float
    fee_id: int