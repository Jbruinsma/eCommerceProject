from _typeshed import _VT_co
from typing import Dict, Any

from fastapi import APIRouter
from fastapi.params import Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql.elements import SQLCoreOperations

from backend.app.pydantic_models.error_message import ErrorMessage
from ..db import get_session

from ..pydantic_models.error_message import ErrorMessage
from ..pydantic_models.updated_user import UpdatedUser
from ..utils.users import update_user

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/{user_uuid}")
async def profile(user_uuid: str, session: AsyncSession = Depends(get_session)) -> Dict[str, str | int] | ErrorMessage:

    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("CALL fetchUserProfileById(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})

    row = result.mappings().first()
    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")

    statement = text("CALL calculatePortfolioValue(:input_user_id);")
    result = await session.execute(statement, {"input_user_id": user_uuid})
    portfolio_value_row = result.mappings().first()

    portfolio_value = portfolio_value_row.total_portfolio_value if portfolio_value_row else 0

    return {
        "firstName": row.firstName,
        "memberSince": row.memberSince,
        "location": row.location,
        "portfolioValue": portfolio_value,
        "activeListings": row.activeListings,
        "openOrders": row.openOrders
    }

@router.get("/{user_uuid}/transactions")
async def transactions(user_uuid: str, session: AsyncSession = Depends(get_session)) -> ErrorMessage | dict[
    str, list[dict[str | SQLCoreOperations[Any], _VT_co]] | int | float]:

    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("CALL retrieveUserTransactionsById(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})
    transaction_rows = result.mappings().all()

    statement = text("CALL retrieveUserBalanceById(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})
    current_balance_row = result.mappings().first()

    statement = text("CALL calculateLifetimeEarnings(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})
    lifetime_earnings_row = result.mappings().first()

    return {
        "transactions": [
            dict(row) for row in transaction_rows
        ],
        "totalTransactions": len(transaction_rows),
        "currentBalance": round(float(current_balance_row.balance), 2),
        "lifetimeEarnings": round(float(lifetime_earnings_row.lifetime_earnings), 2)
    }

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

    if user_uuid != updated_user_settings.uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    return await update_user(updated_user_settings, session)

@router.get("/{user_uuid}/balance")
async def balance(user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="Invalid user UUID", error="InvalidUserUUID")

    statement = text("CALL retrieveUserBalanceById(:input_uuid);")
    result = await session.execute(statement, {"input_uuid": user_uuid})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")

    return dict(row)