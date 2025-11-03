from typing import Optional

from pydantic import BaseModel


class SizeInfo(BaseModel):
    size: Optional[str | int] = None
    sizeId: Optional[int] = None