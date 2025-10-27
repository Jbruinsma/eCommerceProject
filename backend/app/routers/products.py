from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.engine import row
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session

from ..pydantic_models.error_message import ErrorMessage
from ..pydantic_models.product import Product

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

        # {
        #     'product_id': 1,
        #     'name': 'Dunk Low "Panda"',
        #     'brand_id': 12,
        #     'brand_name': 'Nike',
        #     'image_url': 'https://images.stockx.com/images/Nike-Dunk-Low-Retro-White-Black-2021-Product.jpg',
        #     'retail_price': Decimal('110.00'),
        #     'sizes': '[{"size_id": 19, "size_value": "14"}, {"size_id": 12, "size_value": "9.5"}, {"size_id": 13, "size_value": "10"}, {"size_id": 14, "size_value": "10.5"}, {"size_id": 15, "size_value": "11"}, {"size_id": 16, "size_value": "11.5"}, {"size_id": 18, "size_value": "13"}, {"size_id": 8, "size_value": "7.5"}, {"size_id": 20, "size_value": "15"}, {"size_id": 17, "size_value": "12"}, {"size_id": 6, "size_value": "6.5"}, {"size_id": 7, "size_value": "7"}, {"size_id": 9, "size_value": "8"}, {"size_id": 4, "size_value": "5.5"}, {"size_id": 10, "size_value": "8.5"}, {"size_id": 5, "size_value": "6"}, {"size_id": 11, "size_value": "9"}, {"size_id": 3, "size_value": "5"}, {"size_id": 2, "size_value": "4.5"}, {"size_id": 1, "size_value": "4"}]'
        # }

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
        Product(
            product_id=product_dict.product_id,
            brand_id= product_dict.brand_id,
            name= product_dict.name,
            sku= product_dict.sku,
            colorway= product_dict.colorway,
            retail_price= float(product_dict.retail_price),
            release_date= product_dict.release_date,
            product_type= product_dict.product_type,
            image_url= product_dict.image_url,
            brand_name= product_dict.brand_name,
            brand_logo_url= product_dict.brand_logo_url
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
