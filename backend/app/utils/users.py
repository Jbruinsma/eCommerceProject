from fastapi import Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from ..pydantic_models.error_message import ErrorMessage
from ..pydantic_models.updated_user import UpdatedUser


async def update_user(updated_user_settings: UpdatedUser, session: AsyncSession = Depends(get_session)) -> dict | ErrorMessage:
    statement = text(
        "CALL updateUser(:input_uuid, :input_email, :input_first_name, :input_last_name, :input_location, :input_birth_date, :input_role)")
    result = await session.execute(statement, {
        "input_uuid": updated_user_settings.uuid,
        "input_email": updated_user_settings.email,
        "input_first_name": updated_user_settings.first_name,
        "input_last_name": updated_user_settings.last_name,
        "input_location": updated_user_settings.location,
        "input_birth_date": updated_user_settings.birth_date,
        "input_role": updated_user_settings.role,
    })
    await session.commit()

    row = result.mappings().first()
    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")
    return dict(row)