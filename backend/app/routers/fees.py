from fastapi import APIRouter, Depends
from sqlalchemy import text

from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session

router = APIRouter(prefix="/fees", tags=["fees"])

@router.get("/seller_fee_percentage")
async def seller_fee(session: AsyncSession = Depends(get_session)):
    statement = text("CALL retrieveActiveSellerFeePercentage();")
    result = await session.execute(statement)
    row = result.mappings().first()
    return dict(row)

@router.get("/buyer_fee_percentage")
async def buyer_fee(session: AsyncSession = Depends(get_session)):
    statement = text("CALL retrieveActiveBuyerFeePercentage();")
    result = await session.execute(statement)
    row = result.mappings().first()
    return dict(row)