from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.pydantic_models.new_bid_info import NewBidInfo

from app.db import get_session

from app.pydantic_models.error_message import ErrorMessage

router = APIRouter(prefix="/bids", tags=["bids"])

@router.post("/{user_uuid}")
async def create_bid(new_bid_info: NewBidInfo, user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if user_uuid != new_bid_info.user_id:
        return ErrorMessage(message="User UUID does not match bid info user ID", error="UserUUIDMismatch")

    bid_amount = new_bid_info.bid_amount
    transaction_fee = new_bid_info.transaction_fee
    product_condition = new_bid_info.product_condition.lower()

    statement = text("CALL createBid(:input_user_id, :input_product_id, :input_product_size, :input_product_condition, :input_bid_amount, :input_transaction_fee, :input_total_amount);")
    result = await session.execute(statement, {
        "input_user_id": new_bid_info.user_id,
        "input_product_id": new_bid_info.product_id,
        "input_product_size": new_bid_info.size,
        "input_product_condition": product_condition,
        "input_bid_amount": bid_amount,
        "input_transaction_fee": transaction_fee,
        "input_total_amount": bid_amount + transaction_fee,
    })

    await session.commit()

    new_bid_row = result.mappings().first()
    if not new_bid_row:
        return ErrorMessage(message="Your bid could not be placed successfully", error="BidCreationFailed")

    return dict(new_bid_row)

@router.get("/{product_id")
async def get_bids(product_id: str, session: AsyncSession = Depends(get_session)):
    statement = text("CALL getBidsByProductId(:input_product_id);")
    result = await session.execute(statement, {"input_product_id": product_id})
    rows = result.mappings().all()
    return list(rows)