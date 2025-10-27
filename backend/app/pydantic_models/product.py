from __future__ import annotations

from datetime import date
from typing import List

from pydantic import BaseModel

from ..pydantic_models.size_info import SizeInfo

class Product(BaseModel):
    productId: int
    name: str
    brandId: int
    brandName: str
    imageUrl: str
    retailPrice: float
    releaseDate: date | None
    productType: str
    sizes: List[SizeInfo]