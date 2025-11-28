from typing import Optional

from pydantic import BaseModel

from datetime import date


class PortfolioItem(BaseModel):
    portfolioItemId: str
    product: dict
    size: dict
    acquisitionDate: Optional[date]
    acquisitionPrice: Optional[float]
    marketValue: Optional[float]
    gainLoss: Optional[float]