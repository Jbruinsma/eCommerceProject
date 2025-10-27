from pydantic import BaseModel


class SizeInfo(BaseModel):
    size: str | int
    sizeId: int