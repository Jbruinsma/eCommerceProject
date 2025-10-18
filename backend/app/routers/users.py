from fastapi import APIRouter
from fastapi.params import Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session

from app.pydantic_models.error_message import ErrorMessage
from app.pydantic_models.updated_user import UpdatedUser

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/{user_uuid}")
async def profile(user_uuid: str, session: AsyncSession = Depends(get_session)):

    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("CALL fetchUserProfileById(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})

    row = result.mappings().first()
    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")
    return {
        "firstName": row.firstName,
        "memberSince": row.memberSince,
        "location": row.location,
        "portfolioValue": 0,
        "activeListings": row.activeListings,
        "openOrders": row.openOrders
    }

@router.get("/{user_uuid}/portfolio")
async def portfolio(user_uuid: str, session: AsyncSession = Depends(get_session)):
    pass

@router.get("/{user_uuid}/orders")
async def orders(user_uuid: str, session: AsyncSession = Depends(get_session)):
    pass

@router.get("/{user_uuid}/transactions")
async def transactions(user_uuid: str, session: AsyncSession = Depends(get_session)):

    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("CALL retrieveUserTransactionsById(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})
    rows = result.mappings().all()

    return [dict(row) for row in rows]

@router.get("/{user_uuid}/listings")
async def listings(user_uuid: str, session: AsyncSession = Depends(get_session)):
    pass

@router.get("/{user_uuid}/settings")
async def get_settings(user_uuid: str, session: AsyncSession = Depends(get_session)):

    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("SELECT uuid, email, first_name, last_name, location, birth_date, role, created_at, updated_at FROM users WHERE uuid = :input_uuid;")
    result = await session.execute(statement, {"input_uuid": user_uuid})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")
    return dict(row)

@router.post("/{user_uuid}/settings")
async def update_settings(user_uuid: str, updated_user_settings: UpdatedUser, session: AsyncSession = Depends(get_session)):

    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    if not updated_user_settings.uuid:
        updated_user_settings.uuid = user_uuid

    if user_uuid != updated_user_settings.uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("CALL updateUser(:input_uuid, :input_email, :input_first_name, :input_last_name, :input_location, :input_birth_date, :input_role)")
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
