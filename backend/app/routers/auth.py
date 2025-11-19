from fastapi import APIRouter, Depends

from ..pydantic_models.login_credentials import LoginCredentials
from ..pydantic_models.message import Message
from ..pydantic_models.error_message import ErrorMessage

from ..db import get_session
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..security import verify_password, get_password_hash
from ..pydantic_models.register_credentials import RegisterCredentials
from ..utils.database_utils import find_user_by_email

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
async def login(login_credentials: LoginCredentials, session: AsyncSession = Depends(get_session)) -> ErrorMessage | Message:
    error_message = ErrorMessage(message="Invalid username or password", error="InvalidCredentials")

    email = login_credentials.email
    user_provided_unhashed_password = login_credentials.password

    if not email or not user_provided_unhashed_password:
        return error_message

    user = await find_user_by_email(session, email)
    if not user or not verify_password(login_credentials.password, user.password):
        return error_message

    return Message(message="Login Successful", extra= {
        "uuid": user.uuid,
        "email": user.email,
        "role": user.role
    })

@router.post("/register")
async def register(registration_credentials: RegisterCredentials, session: AsyncSession = Depends(get_session)):
    user_provided_email = registration_credentials.email
    user_provided_unhashed_password = registration_credentials.password
    user_provided_confirmation_password = registration_credentials.password_confirmation

    if not user_provided_email or not user_provided_unhashed_password or not user_provided_confirmation_password:
        return {"message": "Invalid credentials"}

    if user_provided_unhashed_password != user_provided_confirmation_password:
        return {"message": "Passwords do not match"}

    user = await find_user_by_email(session, user_provided_email)
    if not user:
        hashed_password = get_password_hash(user_provided_unhashed_password)

        statement = text("CALL createNewUser(:input_email, :input_hashed_password, :input_role);")
        result = await session.execute(statement, {
            "input_email": user_provided_email,
            "input_hashed_password": hashed_password,
            "input_role": "user"
        })
        await session.commit()

        new_user_info_row = result.mappings().first()
        if not new_user_info_row:
            return ErrorMessage(message="User could not be registered", error="UserRegistrationFailed")

        return Message(message="User registered successfully", extra=dict(new_user_info_row))

    return ErrorMessage(message="The email provided is already associated with another account.", error="UserAlreadyExists")
