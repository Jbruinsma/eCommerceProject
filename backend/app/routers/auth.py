from fastapi import APIRouter

from app.pydantic_models.login_credentials import LoginCredentials

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
def login(login_credentials : LoginCredentials):
    print(login_credentials)
    return {"message": "Hello World"}

@router.post("/register")
def register():
    return {"message": "Hello World"}
