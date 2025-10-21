from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
import logging
import sys

from .db import engine, Base
from .routers.users import router as users_router
from .routers.auth import router as auth_router
from .routers.products import router as products_router
from .routers.listings import router as listings_router
from .routers.portfolio import router as portfolio_router
from .routers.bids import router as bids_router
from .routers.orders import router as orders_router
from.routers.admin import router as admin_router

from .config import settings

@asynccontextmanager
async def lifespan(app):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()


app = FastAPI(title="Ecommerce API", lifespan=lifespan)

origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users_router)
app.include_router(auth_router)
app.include_router(products_router)
app.include_router(listings_router)
app.include_router(portfolio_router)
app.include_router(bids_router)
app.include_router(orders_router)
app.include_router(admin_router)


@app.get("/health")
async def health():
    return { "status": "ok", "database": settings.DB_NAME }
