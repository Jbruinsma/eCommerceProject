from typing import Optional

from pydantic import BaseModel


class BidInfo(BaseModel):
    amount: Optional[float] = None
    bidId: Optional[str] = None