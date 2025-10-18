from sqlalchemy import select

from app.models import User
from sqlalchemy.ext.asyncio import AsyncSession


async def find_user_by_email(session: AsyncSession, email: str):
    statement = select(User).where(User.email == email)
    result = await session.execute(statement)
    return result.scalar_one_or_none()