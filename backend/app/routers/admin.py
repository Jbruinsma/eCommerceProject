from fastapi import APIRouter
from fastapi.params import Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from ..pydantic_models.error_message import ErrorMessage

import re
import uuid

router = APIRouter(prefix="/admin", tags=["admin"])


def is_uuid(val: str) -> bool:
    """Return True if val is a valid UUID string."""
    if not val or not isinstance(val, str):
        return False
    try:
        uuid.UUID(val)
        return True
    except (ValueError, AttributeError, TypeError):
        return False


def is_email(val: str) -> bool:
    """Return True if val looks like an email address.

    Uses a conservative regex that covers common valid addresses without implementing full RFC 5322.
    """
    if not val or not isinstance(val, str):
        return False
    email_regex = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
    return re.match(email_regex, val) is not None


def identify_identifier(val: str) -> str:
    """Identify whether `val` is 'uuid', 'email', or 'unknown'."""
    if is_uuid(val):
        return "uuid"
    if is_email(val):
        return "email"
    return "unknown"


@router.get("/{user_identifier}/balance")
async def get_balance(user_identifier: str, session: AsyncSession = Depends(get_session)):
    if not user_identifier:
        return ErrorMessage(message="User identifier is required", error="MissingUserIdentifier")

    id_type = identify_identifier(user_identifier)
    if id_type == "unknown":
        return ErrorMessage(message="User identifier must be an email or UUID", error="InvalidIdentifier")

    statement = text("CALL retrieveCompleteUserProfile(:input_uuid, :input_email)")
    result = await session.execute(statement, {"input_uuid": user_identifier, "input_email": user_identifier})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")

    return dict(row)

@router.post("/{user_identifier}/balance")
def modify_balance(user_identifier: str, new_balance: float, session: AsyncSession = Depends(get_session)):
    if not user_identifier:
        return ErrorMessage(message="User identifier is required", error="MissingUserIdentifier")

    if not new_balance:
        return ErrorMessage(message="New balance is required", error="MissingNewBalance")

    id_type = identify_identifier(user_identifier)
    if id_type == "unknown":
        return ErrorMessage(message="User identifier must be an email or UUID", error="InvalidIdentifier")

    statement = text("CALL recordTransaction(:input_user_id, :input_order_id, :input_amount, :input_transaction_status, :input_payment_origin, :input_payment_destination, :input_payment_purpose);)")