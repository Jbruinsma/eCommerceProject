from typing import Optional
from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session

from ..pydantic_models.error_message import ErrorMessage
from ..pydantic_models.product import ProductBase

from ..utils.bids import process_bids
from ..utils.formatting import format_market_data

router = APIRouter(prefix="/product", tags=["products"])

@router.get("/brands")
async def brands(session: AsyncSession = Depends(get_session)):
    statement = text("CALL retrieveAllBrands();")
    result = await session.execute(statement)
    rows = result.mappings().all()

    return list(rows)

@router.get("/search")
async def search_for_product(
        brand_id: Optional[int] = None,
        brand_name: Optional[str] = None,
        product_name: Optional[str] = None,
        results_per_page: Optional[int] = 50,
        session: AsyncSession = Depends(get_session),
):
    statement = text("CALL productSearch(:input_brand_id, :input_brand_name, :input_product_name, :result_limit);")
    result = await session.execute(statement, {
        "input_brand_id": brand_id,
        "input_brand_name": brand_name,
        "input_product_name": product_name,
        "result_limit": results_per_page,
    })
    rows = result.mappings().all()
    return list(rows)

@router.get("/search/general")
async def general_search(
        brand_id: Optional[int] = None,
        brand_name: Optional[str] = None,
        product_name: Optional[str] = None,
        results_per_page: Optional[int] = 50,
        session: AsyncSession = Depends(get_session),
):
    statement = text("CALL generalProductSearch(:input_brand_id, :input_brand_name, :input_product_name, :result_limit);")
    result = await session.execute(statement, {
        "input_brand_id": brand_id,
        "input_brand_name": brand_name,
        "input_product_name": product_name,
        "result_limit": results_per_page,
    })
    rows = result.mappings().all()

    print("\n---\n", rows)

    return list(rows)

@router.get("/search/category")
async def search_for_products_by_category(
        category: Optional[str] = None,
        session: AsyncSession = Depends(get_session),
):
    statement = text("CALL retrieveProductsByCategory(:input_category, :result_limit);")
    result = await session.execute(statement, {
        "input_category": category,
        "result_limit": 50,
    })
    product_rows = result.mappings().all()

    return [
        ProductBase(
            productId=product_dict.product_id,
            brandId= product_dict.brand_id,
            name= product_dict.name,
            retailPrice= float(product_dict.retail_price) if product_dict.retail_price is not None else None,
            releaseDate= product_dict.release_date,
            productType= product_dict.product_type,
            imageUrl= product_dict.image_url,
            brandName= product_dict.brand_name,
            lowestAskingPrice=None,
        ) for product_dict in product_rows
    ]

@router.get("/{product_id}")
async def product(product_id: str, session: AsyncSession = Depends(get_session)):
    statement = text("CALL retrieveProductById(:input_product_id);")
    product_result = await session.execute(statement, {"input_product_id": product_id})
    product_row = product_result.mappings().first()
    if not product_row:
        return ErrorMessage(message="Product not found", error="ProductNotFound")

    statement = text("CALL retrieveAllProductSizes(:input_product_id);")
    size_result = await session.execute(statement, {"input_product_id": product_id})
    size_rows = size_result.mappings().all()
    all_product_sizes = list(size_rows)

    statement = text("CALL retrieveLowestAsksByProductId(:input_product_id);")
    lowest_ask_result = await session.execute(statement, {"input_product_id": product_id})
    lowest_ask_rows = lowest_ask_result.mappings().all()

    statement = text("CALL getBidsByProductId(:input_product_id);")
    bids_results = await session.execute(statement, {"input_product_id": product_id})
    bids_rows = bids_results.mappings().all()
    processed_bids = process_bids(bids_rows)

    return {
        "marketData": format_market_data(all_product_sizes, list(lowest_ask_rows), processed_bids),
        "sizes": all_product_sizes,
        "productInfo": dict(product_row),
        "bids": processed_bids
    }
