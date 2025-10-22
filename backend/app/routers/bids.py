from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..pydantic_models.edited_bid import EditedBid
from ..pydantic_models.message import Message
from ..pydantic_models.new_bid_info import NewBidInfo

from ..db import get_session

from ..pydantic_models.error_message import ErrorMessage

router = APIRouter(prefix="/bids", tags=["bids"])

@router.get("/{user_uuid}")
async def get_user_bids(user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL retrieveBidsByUserId(:input_user_id);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid
    })
    rows = result.mappings().all()
    return list(rows)

@router.get("/{user_uuid}/active")
async def get_active_bids(user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL retrieveActiveBidsByUserId(:input_user_id);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid
    })
    rows = result.mappings().all()
    return list(rows)

@router.post("/{user_uuid}/{bid_id}/edit")
async def edit_bid(bid_id: str, user_uuid: str, updated_bid_info: EditedBid,  session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if not bid_id:
        return ErrorMessage(message="Bid ID is required", error="MissingBidID")

    if bid_id != updated_bid_info.bid_id:
        return ErrorMessage(message="Bid ID does not match bid info bid ID", error="BidIDMismatch")

    statement = text("CALL updateBid(:input_bid_id, :input_bid_amount, :input_fee_structure_id);")
    result = await session.execute(statement, {
        "input_bid_id": bid_id,
        "input_bid_amount": updated_bid_info.new_bid_amount,
        "input_fee_structure_id": updated_bid_info.fee_structure_id,
    })
    await session.commit()

    updated_bid_row = result.mappings().first()
    if not updated_bid_row:
        return ErrorMessage(message="Your bid could not be updated successfully", error="BidUpdateFailed")

    return dict(updated_bid_row)

@router.delete("/{user_uuid}/{bid_id}")
async def delete_bid(bid_id: str, user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if not bid_id:
        return ErrorMessage(message="Bid ID is required", error="MissingBidID")

    statement = text("CALL deleteBid(:input_bid_id);")
    result = await session.execute(statement, {"input_bid_id": bid_id})
    await session.commit()

    return Message(
        message="Bid deleted successfully",
        extra={}
    )

@router.post("/{user_uuid}")
async def create_bid(new_bid_info: NewBidInfo, user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if user_uuid != new_bid_info.user_id:
        return ErrorMessage(message="User UUID does not match bid info user ID", error="UserUUIDMismatch")

    bid_amount = new_bid_info.bid_amount
    transaction_fee = new_bid_info.transaction_fee
    transaction_fee_id = new_bid_info.transaction_fee_rate_id
    product_condition = new_bid_info.product_condition.lower()

    statement = text("CALL createBid(:input_user_id, :input_product_id, :input_product_size, :input_product_condition, :input_bid_amount, :input_transaction_fee, :input_fee_structure_id, :input_total_amount);")
    result = await session.execute(statement, {
        "input_user_id": new_bid_info.user_id,
        "input_product_id": new_bid_info.product_id,
        "input_product_size": new_bid_info.size,
        "input_product_condition": product_condition,
        "input_bid_amount": bid_amount,
        "input_transaction_fee": transaction_fee,
        "input_fee_structure_id": transaction_fee_id,
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