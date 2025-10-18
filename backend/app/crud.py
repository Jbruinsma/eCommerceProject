from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from .models import User
from .schemas import UserCreate
import hashlib


async def get_user_by_uuid(session: AsyncSession, user_uuid: str):
    q = select(User).where(User.uuid == user_uuid)
    res = await session.execute(q)
    return res.scalars().first()


async def get_user_by_email(session: AsyncSession, email: str):
    # ensure email is a plain str (handles pydantic EmailStr)
    email = str(email)
    q = select(User).where(User.email == email)
    res = await session.execute(q)
    return res.scalars().first()


async def create_user(session: AsyncSession, user_in: UserCreate):
    # NOTE: This uses a simple sha256 for demonstration only. Use a proper password hashing library (passlib) in production.
    hashed = hashlib.sha256(user_in.password.encode()).hexdigest()
    user = User(email=str(user_in.email), password=hashed, first_name=user_in.first_name, last_name=user_in.last_name)
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


async def list_users(session: AsyncSession, limit: int = 100):
    q = select(User).limit(limit)
    res = await session.execute(q)
    return res.scalars().all()
