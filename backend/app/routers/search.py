from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from ..pydantic_models.error_message import ErrorMessage
from ..pydantic_models.product import Product
from ..pydantic_models.size_info import SizeInfo
from ..utils.formatting import format_size_dict, make_json_safe

router = APIRouter(prefix="/search", tags=["search"])

@router.get("/")
async def search(
        q: Optional[str] = None,
        category: Optional[str] = None,
        brand_id: Optional[int] = None,
        result_limit: Optional[int] = 50,
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
                Product(
                    productId= product_dict.product_id,
                    name= product_dict.name,
                    brandId= product_dict.brand_id,
                    brandName= product_dict.brand_name,
                    imageUrl= product_dict.image_url,
                    retailPrice= product_dict.retail_price,
                    releaseDate= product_dict.release_date,
                    productType= product_dict.product_type,
                    sizes= [
                        SizeInfo(
                            size= size_dict['size_value'],
                            sizeId= size_dict['size_id']
                        ) for size_dict in make_json_safe(product_dict.sizes)
                    ]
                ) for product_dict in product_rows
            ],
        "filters": format_filters(product_rows)
    }

def format_filters(product_rows):
    return {
        "brands": set(product_dict.brand_name for product_dict in product_rows),
        "categories":  set(product_dict.product_type for product_dict in product_rows)
    }
