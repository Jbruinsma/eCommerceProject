from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session

from app.pydantic_models.new_listing_info import NewListingInfo

from app.pydantic_models.error_message import ErrorMessage

router = APIRouter(prefix="/listings", tags=["listings"])

@router.post("/{user_uuid}/create")
async def create_listing(user_uuid: str, new_listing_info: NewListingInfo, session: AsyncSession = Depends(get_session)):
    statement = text("CALL addListing(:input_user_id, :input_product_id, :input_size_id, :input_listing_type, :input_price, :input_condition);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid,
        "input_product_id": new_listing_info.product_id,
        "input_size_id": new_listing_info.size_id,
        "input_listing_type": new_listing_info.listing_type,
        "input_price": new_listing_info.price,
        "input_condition": new_listing_info.item_condition,
    })
    await session.commit()

    row = result.mappings().first()
    if not row:
        return ErrorMessage(message="Your item could not be listed successfully", error="ListingNotFound")

    return dict(row)