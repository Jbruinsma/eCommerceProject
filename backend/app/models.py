import uuid
from sqlalchemy import Column, String, DateTime, Date
from sqlalchemy.sql import func
from sqlalchemy.dialects.mysql import VARCHAR, ENUM as MySQLEnum

from .db import Base


def gen_uuid() -> str:
    return str(uuid.uuid4())


class User(Base):
    __tablename__ = "users"

    uuid = Column(VARCHAR(36), primary_key=True, nullable=False, default=gen_uuid)
    email = Column(String(225), nullable=False, unique=True)
    password = Column(String(255), nullable=False)
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    birth_date = Column(Date, nullable=True)
    role = Column(MySQLEnum('user', 'admin', name='role_enum'), nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), server_onupdate=func.now(), nullable=True)
