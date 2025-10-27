from __future__ import annotations

from datetime import date
from typing import List

from pydantic import BaseModel

from .complete_size_info import CompleteSizeInfo
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
    sizes: List[SizeInfo | CompleteSizeInfo]