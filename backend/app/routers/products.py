from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from ..utils.products import retrieve_product_id, retrieve_product_info

router = APIRouter(prefix="/product", tags=["products"])



@router.get("/featured")
async def retrieve_featured_products(session: AsyncSession = Depends(get_session)):
    banner_skus = ["S57WS0240P1892-961", "S57WS0236P1895H6851"]
    homepage_skus = ["313171-004", "AV4168-776", "CW7093-600", "313171-300"]

    banner_product_ids = [ await retrieve_product_id(banner_sku, session) for banner_sku in banner_skus]
    homepage_product_ids = [await retrieve_product_id(homepage_sku, session) for homepage_sku in homepage_skus]

    banner_product_info = [ await retrieve_product_info(product_id, session) for product_id in banner_product_ids]
    homepage_product_info = [ await retrieve_product_info(product_id, session) for product_id in homepage_product_ids]

    return {
        "bannerProduct": {
            "productInfo": banner_product_info,
            "text": {
                "image": "/images/MaisonMargielaBanner.png",
                "header": "History, Refined.",
                "subtext": "Shop Maison Margiela on The Vault today."
            }
        },
        "homepageProducts": homepage_product_info
    }

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
