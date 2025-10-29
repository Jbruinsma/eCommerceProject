from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..pydantic_models.error_message import ErrorMessage


async def retrieve_user_orders(user_uuid: str, session: AsyncSession):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL retrieveAllOrdersByUserId(:input_user_id);")
    result = await session.execute(statement, {"input_user_id": user_uuid})
    rows = result.mappings().all()

    if not rows:
        return ErrorMessage(message="No orders found", error="NoOrdersFound")

    return list(rows)