from pydantic import BaseModel


class ModifiedBalanceInfo(BaseModel):
    uuid: str
    change: int
    reason: str