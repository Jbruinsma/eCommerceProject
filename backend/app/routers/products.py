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

@router.get("/history/{product_id}")
async def product(product_id: str, session: AsyncSession = Depends(get_session)):
    statement = text("CALL retrieveAllProductSizes(:input_product_id);")
    size_result = await session.execute(statement, {"input_product_id": product_id})
    size_rows = size_result.mappings().all()
    all_product_sizes = list(size_rows)

    # print(all_product_sizes)

    product_history = {}

    for size_dict in all_product_sizes:
        size_id = size_dict.get("size_id", None)
        size_value = size_dict.get("size_value", None)

        # print(size_id, size_value)

        if size_id is None or size_value is None: continue

        product_history[size_id] = {
            "sizeValue": size_value,
            "new": [],
            "used": [],
            "worn": []
        }

    for size_id in product_history:
        for condition in product_history[size_id]:
            if condition == "sizeValue": continue

            statement = text("CALL retrieveSaleHistory(:input_product_id, :input_size, :input_condition, :input_result_limit);")
            result = await session.execute(statement, {
                "input_product_id": int(product_id),
                "input_size": int(size_id),
                "input_condition": condition,
                "input_result_limit": None
            })
            rows = result.mappings().all()
            product_history[size_id][condition] = list(rows)

    return product_history
