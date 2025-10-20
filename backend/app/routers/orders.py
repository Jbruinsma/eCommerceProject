from fastapi import APIRouter, Depends

from app.pydantic_models.login_credentials import LoginCredentials
from app.pydantic_models.message import Message
from app.pydantic_models.error_message import ErrorMessage

from app.db import get_session
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.pydantic_models.new_order import NewOrder

router = APIRouter(prefix="/orders", tags=["orders"])

@router.post("/{listing_id}")
async def fulfil_order(listing_id: str, new_order_summary: NewOrder, session: AsyncSession = Depends(get_session)):
    if not listing_id:
        return ErrorMessage(message="Listing ID is required", error="MissingListingID")

    if listing_id != new_order_summary.listing_id:
        return ErrorMessage(message="Listing ID does not match shipping info listing ID", error="ListingIDMismatch")

    print(new_order_summary)

    address = new_order_summary.shipping_info

    statement = text("CALL addAddress(:input_user_id, :input_name, :input_address_line1, :input_address_line2, :input_city, :input_state, :input_zip_code, :input_country);")
    result = await session.execute(statement, {
        "input_user_id": new_order_summary.buyer_id,
        "input_name": address.name,
        "input_address_line1": address.address_line_1,
        "input_address_line2": address.address_line_2,
        "input_city": address.city,
        "input_state": address.state,
        "input_zip_code": address.zip_code,
        "input_country": address.country,
    })
    await session.commit()
    address_row = result.mappings().first()

    statement = text("CALL newOrder(:input_buyer_id, :input_listing_id, :input_transaction_fee, :input_payment_method)")
    result = await session.execute(statement, {
        "input_buyer_id": new_order_summary.buyer_id,
        "input_listing_id": new_order_summary.listing_id,
        "input_transaction_fee": new_order_summary.transaction_fee,
        "input_payment_method": new_order_summary.payment_method,
    })
    await session.commit()

    new_order = result.mappings().first()
    if not new_order:
        return ErrorMessage(message="Order could not be fulfilled", error="OrderFulfillmentFailed")

    return dict(new_order)