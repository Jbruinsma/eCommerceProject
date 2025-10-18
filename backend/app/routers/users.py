from fastapi import APIRouter
from fastapi.params import Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session

from app.pydantic_models.error_message import ErrorMessage

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
async def settings(user_uuid: str, session: AsyncSession = Depends(get_session)):
    pass