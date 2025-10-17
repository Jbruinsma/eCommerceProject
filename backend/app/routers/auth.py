from fastapi import APIRouter

from backend.pydantic_models.login_credentials import LoginCredentials

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/login")
def login(login_credentials : LoginCredentials):
    print(login_credentials)
    return {"message": "Hello World"}

@router.get("/register")
def register():
    return {"message": "Hello World"}