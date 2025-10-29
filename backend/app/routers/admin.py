from fastapi import APIRouter
from fastapi.params import Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from ..pydantic_models.error_message import ErrorMessage

import re
import uuid

from ..pydantic_models.modified_balance_info import ModifiedBalanceInfo
from ..pydantic_models.updated_order import UpdatedOrder
from ..pydantic_models.updated_user import UpdatedUser
from ..utils.orders import retrieve_user_orders
from ..utils.users import update_user

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
    try:
        user_uuid, user_email = retrieve_uuid_and_email(user_identifier, session)
    except Exception as e:
        return ErrorMessage(message=str(e), error="InvalidIdentifier")

    statement = text("CALL retrieveCompleteUserProfile(:input_uuid, :input_email)")
    result = await session.execute(statement, {"input_uuid": user_uuid, "input_email": user_email})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")

    return dict(row)

@router.post("/{user_identifier}/balance")
async def modify_balance(user_identifier: str, modified_balance_info: ModifiedBalanceInfo, session: AsyncSession = Depends(get_session)):
    try:
        user_uuid, user_email = retrieve_uuid_and_email(user_identifier, session)
    except Exception as e:
        return ErrorMessage(message=str(e), error="InvalidIdentifier")

    if user_uuid != modified_balance_info.uuid:
        return ErrorMessage(message="User identifier does not match UUID", error="InvalidIdentifier")


    statement = text("CALL recordTransaction(:input_user_id, :input_order_id, :input_amount, :input_transaction_status, :input_payment_origin, :input_payment_destination, :input_payment_purpose);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid,
        "input_order_id": None,
        "input_amount": modified_balance_info.change,
        "input_transaction_status": "completed",
        "input_payment_origin": "other",
        "input_payment_destination": "account_balance",
        "input_payment_purpose": modified_balance_info.reason,

    })

    await session.commit()

    new_transaction_row = result.mappings().first()
    if not new_transaction_row:
        return ErrorMessage(message="Transaction could not be recorded", error="TransactionRecordingFailed")

    statement = text("CALL updateBalance(:input_user_id, :input_email, :input_balance_adjustment_amount);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid,
        "input_email": user_identifier,
        "input_balance_adjustment_amount": modified_balance_info.change,
    })

    await session.commit()

    updated_balance_row = result.mappings().first()
    if not updated_balance_row:
        return ErrorMessage(message="Balance could not be updated", error="BalanceUpdateFailed")

    return {
        "newBalance": updated_balance_row.balance,
        "transaction": dict(new_transaction_row)
    }

@router.get("/users/{user_identifier:path}")
async def get_user_info(user_identifier: str, session: AsyncSession = Depends(get_session)):
    try:
        user_uuid, user_email = retrieve_uuid_and_email(user_identifier, session)
    except Exception as e:
        return ErrorMessage(message=str(e), error="InvalidIdentifier")

    statement = text("CALL retrieveCompleteUserProfile(:input_uuid, :input_email);")
    result = await session.execute(statement, {"input_uuid": user_uuid, "input_email": user_email})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="User not found", error="UserNotFound")
    return dict(row)

@router.post("/users/{user_uuid}")
async def modify_user(user_uuid: str, updated_user_settings : UpdatedUser, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if user_uuid != updated_user_settings.uuid:
        return ErrorMessage(message="User UUID does not match user info UUID", error="UserUUIDMismatch")

    return await update_user(updated_user_settings, session)

@router.get("/orders/{user_identifier:path}")
async def get_orders(user_identifier: str, session: AsyncSession = Depends(get_session)):
    try:
        user_uuid, user_email = await retrieve_uuid_and_email(user_identifier, session)
    except Exception as e:
        return ErrorMessage(message=str(e), error="InvalidIdentifier")

    return await retrieve_user_orders(user_uuid, session)

@router.post("/orders/{user_identifier:path}/{order_id}")
async def modify_order(user_identifier: str, order_id: str, updated_order: UpdatedOrder, session: AsyncSession = Depends(get_session)):
    try:
        user_uuid, user_email = await retrieve_uuid_and_email(user_identifier, session)
    except Exception as e:
        return ErrorMessage(message=str(e), error="InvalidIdentifier")

    if updated_order.user_identifier not in (user_uuid, user_email):
        return ErrorMessage(message="User identifier does not match order info user identifier", error="UserUUIDMismatch")

    statement = text("CALL retrieveOrderById(:input_order_id);")
    result = await session.execute(statement, {"input_order_id": order_id})
    order_row = result.mappings().first()

    if not order_row:
        return ErrorMessage(message="Order not found", error="OrderNotFound")

    seller_id = order_row.seller_id

    if user_uuid not in (order_row.buyer_id, seller_id):
        return ErrorMessage(message="User does not have permission to modify order", error="PermissionDenied")

    order_status = order_row.status

    if order_status not in ("pending", "completed", "cancelled"):
        return ErrorMessage(message="Invalid order status", error="InvalidOrderStatus")

    updated_order_row = None

    if order_status != "completed" and updated_order.status == "completed":
        statement = text("CALL completeOrder(:input_order_id, :input_seller_id);")
        result = await session.execute(statement, {"input_order_id": order_id, "input_seller_id": seller_id})
        await session.commit()
        updated_order_row = result.mappings().first()
    else:
        statement = text("CALL updateOrderStatus(:input_order_id, :input_status);")
        result = await session.execute(statement, {"input_order_id": order_id, "input_status": updated_order.status})
        await session.commit()
        updated_order_row = result.mappings().first()

    if not updated_order_row:
        return ErrorMessage(message="Order status could not be updated", error="OrderUpdateFailed")
    return dict(updated_order_row)

async def retrieve_uuid_and_email(user_identifier: str, session: AsyncSession = Depends(get_session)):
    if not user_identifier:
        return ErrorMessage(message="User identifier is required", error="MissingUserIdentifier")

    id_type = identify_identifier(user_identifier)
    if id_type == "unknown":
        return ErrorMessage(message="User identifier must be an email or UUID", error="InvalidIdentifier")

    user_uuid = None
    user_email = None

    if id_type == "uuid":
        user_uuid = user_identifier
        statement = text("SELECT email FROM users WHERE uuid = :input_uuid;")
        result = await session.execute(statement, {"input_uuid": user_identifier})
        row = result.mappings().first()
        if not row:
            raise Exception("User not found")
        user_email = row.email
    elif id_type == "email":
        user_email = user_identifier
        statement = text("SELECT uuid FROM users WHERE email = :input_email;")
        result = await session.execute(statement, {"input_email": user_identifier})
        row = result.mappings().first()
        if not row:
            return Exception("User not found")
        user_uuid = row.uuid
    else:
        raise Exception("Invalid identifier type")

    return user_uuid, user_email