from typing import Optional

from pydantic import BaseModel


class AskInfo(BaseModel):
    price: Optional[float] = None
    listingId: Optional[str] = None