from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


async def retrieve_product_id(sku, session: AsyncSession):
    statement = text("CALL retrieveProductIdBySku(:input_sku);")

    result = await session.execute(statement, {"input_sku": sku})
    banner_product_row = result.mappings().first()
    return banner_product_row.product_id if banner_product_row else None

async def retrieve_product_info(product_id, session: AsyncSession):
    statement = text("CALL searchProductByProductId(:input_product_id);")
    result = await session.execute(statement, {"input_product_id": product_id})
    banner_product_row = result.mappings().first()
    return dict(banner_product_row) if banner_product_row else None