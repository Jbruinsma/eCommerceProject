from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session

from ..pydantic_models.new_listing_info import NewListingInfo

from ..pydantic_models.error_message import ErrorMessage

from ..pydantic_models.sale_info import SaleInfo

router = APIRouter(prefix="/listings", tags=["listings"])

@router.post("/{user_uuid}/create")
async def create_listing(user_uuid: str, new_listing_info: NewListingInfo, session: AsyncSession = Depends(get_session)):
    statement = text("CALL createListing(:input_user_id, :input_product_id, :input_size_id, :input_listing_type, :input_price, :input_fee_structure_id, :input_condition);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid,
        "input_product_id": new_listing_info.product_id,
        "input_size_id": new_listing_info.size_id,
        "input_listing_type": new_listing_info.listing_type,
        "input_price": new_listing_info.price,
        "input_fee_structure_id": new_listing_info.fee_id,
        "input_condition": new_listing_info.item_condition,
    })
    await session.commit()

    row = result.mappings().first()
    if not row:
        return ErrorMessage(message="Your item could not be listed successfully", error="ListingNotFound")

    return dict(row)

@router.post("/{user_uuid}/fulfill")
async def fulfill_listing(user_uuid: str, sale_info: SaleInfo, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if sale_info.listing_type != "sale":
        return ErrorMessage(message="Listing type must be 'sale'", error="InvalidListingType")

    statement = text("CALL retrieveBidById(:input_bid_id);")
    result = await session.execute(statement, {"input_bid_id": sale_info.target_bid_id})
    target_bid_row = result.mappings().first()

    if not target_bid_row:
        return ErrorMessage(message="Bid not found", error="BidNotFound")

    bider_uuid = target_bid_row.user_id
    bid_payment_method = target_bid_row.payment_origin
    total_bid_amount = target_bid_row.total_bid_amount

    if bid_payment_method == "account_balance":
        statement = text("CALL retrieveUserBalanceById(:input_uuid)")
        result = await session.execute(statement, {"input_uuid": user_uuid})
        user_balance_row = result.mappings().first()
        user_balance = user_balance_row.balance

        if user_balance - total_bid_amount < 0:
            return ErrorMessage(message="Insufficient funds", error="InsufficientFunds")

    statement = text("CALL connectListingToBid(:input_product_id, :input_seller_id, :input_bid_id, :input_listing_id, :input_sale_price, :input_size_id, :input_seller_fee_structure_id);")
    result = await session.execute(statement, {
        "input_product_id": sale_info.product_id,
        "input_seller_id": user_uuid,
        "input_bid_id": sale_info.target_bid_id,
        "input_listing_id": None,
        "input_sale_price": sale_info.price,
        "input_size_id": sale_info.size_id,
        "input_seller_fee_structure_id": sale_info.fee_id,
    })
    await session.commit()

    new_order_row = result.mappings().first()
    if not new_order_row:
        return ErrorMessage(message="An error occurred fulfilling order.", error="OrderFulfillmentFailed")

    buyer_final_price = new_order_row.buyer_final_price
    buyer_payment_origin = 'other'

    if bid_payment_method == "account_balance":
        buyer_payment_origin = 'account_balance'
        statement = text("CALL updateBalance(:input_uuid, :input_email, :input_balance_adjustment_amount);")
        await session.execute(statement, {
            "input_uuid": bider_uuid,
            "input_email": None,
            "input_balance_adjustment_amount": -1 * buyer_final_price,
        })
        await session.commit()

    statement = text("CALL recordTransaction(:input_user_id, :input_order_id, :input_amount, :input_transaction_status, :input_payment_origin, :input_payment_destination, :input_payment_purpose);")
    result = await session.execute(statement, {
        "input_user_id": bider_uuid,
        "input_order_id": new_order_row.order_id,
        "input_amount": buyer_final_price,
        "input_transaction_status": "completed",
        "input_payment_origin": buyer_payment_origin,
        "input_payment_destination": "account_balance",
        "input_payment_purpose": "sale_proceeds",
    })
    await session.commit()
    transaction_row = result.mappings().first()
    if not transaction_row:
        return ErrorMessage(message="An error occurred recording transaction.", error="TransactionRecordingFailed")

    return dict(new_order_row)

@router.get("/{user_uuid}")
async def listings(user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL retrieveAllListingsByUserId(:input_user_id);")
    result = await session.execute(statement, {"input_user_id": user_uuid})
    rows = result.mappings().all()

    if not rows: return []
    return list(rows)

@router.get("/{user_uuid}/{listing_id}")
async def user_listing(user_uuid: str, listing_id: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if not listing_id:
        return ErrorMessage(message="Listing ID is required", error="MissingListingID")

    statement = text("CALL retrieveListingById(:input_listing_id, :input_user_id);")
    result = await session.execute(statement, {"input_listing_id": listing_id, "input_user_id": user_uuid})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="Listing not found", error="ListingNotFound")

    return dict(row)

@router.get("/active/id/{listing_id}")
async def listing(listing_id: int, session: AsyncSession = Depends(get_session)):
    if not listing_id:
        return ErrorMessage(message="Listing ID is required", error="MissingListingID")

    statement = text("CALL retrieveSpecificActiveListing(:input_listing_id);")
    result = await session.execute(statement, {"input_listing_id": int(listing_id)})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="Listing not found", error="ListingNotFound")

    return dict(row)
