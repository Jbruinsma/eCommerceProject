from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session

from ..pydantic_models.new_portfolio_item import NewPortfolioItem

from ..pydantic_models.error_message import ErrorMessage

from ..pydantic_models.portfolio_item import PortfolioItem

router = APIRouter(prefix="/portfolio", tags=["portfolio"])

@router.get("/{user_uuid}")
async def portfolio(user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL retrieveAllPortfolioItemsByUserId(:input_user_id);")
    result = await session.execute(statement, {"input_user_id": user_uuid})
    new_portfolio_item_row = result.mappings().all()

    if not new_portfolio_item_row: return []

    return [
        PortfolioItem(
            portfolioItemId= row.portfolio_item_id,
            product= {
                "productId": row.product_id,
                "name": row.product_name,
                "image_url": row.product_image_url
            },
            size= {
                "sizeId": row.size_id,
                "sizeValue": row.size_value
            },
            acquisitionDate= row.acquisition_date,
            acquisitionPrice= row.acquisition_price,
            marketValue= round(float(row.estimated_current_value), 2) if row.estimated_current_value else None,
            gainLoss= round(float(row.profit_loss), 2) if row.profit_loss else None
        ) for row in new_portfolio_item_row
    ]

@router.post("/{user_uuid}")
async def add_portfolio_item(user_uuid: str, new_portfolio_item_info: NewPortfolioItem, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL addNewPortfolioItem(:input_user_id, :input_product_id, :input_size_id, :input_purchase_date, :input_purchase_price, :input_condition);")
    result = await session.execute(statement, {
        "input_user_id": user_uuid,
        "input_product_id": new_portfolio_item_info.product_id,
        "input_size_id": new_portfolio_item_info.size_id,
        "input_purchase_date": new_portfolio_item_info.acquisition_date,
        "input_purchase_price": new_portfolio_item_info.acquisition_price,
        "input_condition": new_portfolio_item_info.item_condition
    })
    await session.commit()

    row = result.mappings().first()
    if not row:
        return ErrorMessage(message="Your item could not be added to your portfolio", error="PortfolioItemAdditionFailed")

    return dict(row)
