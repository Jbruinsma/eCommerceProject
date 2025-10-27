from typing import Dict, Optional

from pydantic import BaseModel

from ..pydantic_models.ask_info import AskInfo
from ..pydantic_models.bid_info import BidInfo


class CompleteSizeInfo(BaseModel):
    size: str | int
    sizeId: int
    highestBid: Dict[str, BidInfo]
    lowestAskingPrice: Dict[str, AskInfo]