from pydantic import BaseModel


class NewPortfolioItem(BaseModel):
    brand_id: int
    product_id: int
    size_id: int
    item_condition: str
    acquisition_date: str | None
    acquisition_price: int
