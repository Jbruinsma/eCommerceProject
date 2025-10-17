from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_session
from .. import crud, schemas

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/")
async def test():
    return {"message": "Hello World"}
