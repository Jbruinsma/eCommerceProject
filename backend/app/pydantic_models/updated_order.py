from pydantic import BaseModel


class UpdatedOrder(BaseModel):
    user_identifier: str
    status: str