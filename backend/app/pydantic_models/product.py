from __future__ import annotations

from datetime import date
from typing import List, Optional

from pydantic import BaseModel

from .complete_size_info import CompleteSizeInfo
from ..pydantic_models.size_info import SizeInfo

class ProductBase(BaseModel):
    productId: int
    name: str
    brandId: int
    brandName: str
    imageUrl: Optional[str] = None,
    retailPrice: Optional[float | int] = None,
    releaseDate: Optional[date] = None,
    productType: str
    lowestAskingPrice: Optional[float] = None,

class ProductSearch(ProductBase):
    sizes: List[SizeInfo]

class ProductDetail(ProductBase):
    sizes: List[CompleteSizeInfo]