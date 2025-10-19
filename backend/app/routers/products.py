from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session

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
        session: AsyncSession = Depends(get_session)
):
    statement = text("CALL ProductSearch(:input_brand_id, :input_brand_name, :input_product_name);")
    result = await session.execute(statement, {
        "input_brand_id": brand_id,
        "input_brand_name": brand_name,
        "input_product_name": product_name
    })
    rows = result.mappings().all()
    return list(rows)

@router.get("/{product_id}")
async def product(product_id: str):
    print(product_id)
    return {
        "message": "Product found"
    }
