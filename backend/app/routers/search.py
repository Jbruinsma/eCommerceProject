from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from ..pydantic_models.ask_info import AskInfo
from ..pydantic_models.bid_info import BidInfo
from ..pydantic_models.complete_size_info import CompleteSizeInfo
from ..pydantic_models.error_message import ErrorMessage
from ..pydantic_models.product import ProductSearch, ProductDetail
from ..pydantic_models.size_info import SizeInfo
from ..utils.formatting import format_size_dict, make_json_safe

router = APIRouter(prefix="/search", tags=["search"])

@router.get("/")
async def search(
        q: Optional[str] = None,
        category: Optional[str] = None,
        brand_id: Optional[int] = None,
        result_limit: Optional[int] = 100,
        session: AsyncSession = Depends(get_session)
):
    statement = text("CALL searchProducts(:input_search_term, :input_category, :input_brand_id, :result_limit);")
    result = await session.execute(statement, {
        "input_search_term": q,
        "input_category": category,
        "input_brand_id": brand_id,
        "result_limit": result_limit,
    })
    product_rows = result.mappings().all()

    return {
        "products":
            [
                ProductSearch(
                    productId= product_dict.product_id,
                    name= product_dict.name,
                    brandId= product_dict.brand_id,
                    brandName= product_dict.brand_name,
                    imageUrl= product_dict.image_url,
                    retailPrice= product_dict.retail_price,
                    releaseDate= product_dict.release_date,
                    productType= product_dict.product_type,
                    lowestAskingPrice= product_dict.lowest_asking_price,
                    sizes= [
                        SizeInfo(
                            size= size_dict['size_value'],
                            sizeId= size_dict['size_id']
                        ) for size_dict in make_json_safe(product_dict.sizes)
                        if size_dict and size_dict.get('size_id') is not None
                    ]
                ) for product_dict in product_rows
            ],
        "filters": format_filters(product_rows)
    }

@router.get("/{product_id}")
async def search_by_product_id(product_id: str, session: AsyncSession = Depends(get_session)):
    if not product_id:
        return ErrorMessage(message="Product ID is required", error="MissingProductID")

    statement = text("CALL searchProductByProductId(:input_product_id);")
    result = await session.execute(statement, {"input_product_id": product_id})
    product_rows = result.mappings().all()

    if not product_rows:
        return ErrorMessage(message="Product not found", error="ProductNotFound")

    product_dict = product_rows[0]

    return ProductDetail(
        productId=product_dict.product_id,
        name=product_dict.name,
        brandId=product_dict.brand_id,
        brandName=product_dict.brand_name,
        imageUrl=product_dict.image_url,
        retailPrice=product_dict.retail_price,
        releaseDate=product_dict.release_date,
        productType=product_dict.product_type,
        lowestAskingPrice=product_dict.lowest_asking_price,
        sizes=[
            CompleteSizeInfo(
                size=size_dict['size_value'],
                sizeId=size_dict['size_id'],
                highestBid={
                    condition: BidInfo(
                        amount=bid_data.get('amount'),
                        bidId=bid_data.get('bid_id')
                    ) for condition, bid_data in size_dict['highest_bid'].items() if bid_data
                },
                lowestAskingPrice={
                    condition: AskInfo(
                        price=ask_data.get('price'),
                        listingId= str(ask_data.get('listing_id'))
                    ) for condition, ask_data in size_dict['lowest_ask'].items() if ask_data
                }
            ) for size_dict in make_json_safe(product_dict.sizes)
            if size_dict and size_dict.get('size_id') is not None
        ]
    )

def format_filters(product_rows):
    return {
        "brands": set(product_dict.brand_name for product_dict in product_rows),
        "categories":  set(product_dict.product_type for product_dict in product_rows)
    }