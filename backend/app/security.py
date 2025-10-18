from passlib.context import CryptContext

# use bcrypt (or add argon2 if preferred)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """Return a bcrypt hash for the given plain password."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Return True if plain_password matches the hashed_password."""
    return pwd_context.verify(plain_password, hashed_password)