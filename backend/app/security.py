import logging
from typing import Union

try:
    import bcrypt
except Exception as e:
    # Import error will be visible when running the app; keep soft-fail so import doesn't crash the module itself
    bcrypt = None
    logging.warning("bcrypt import failed: %s", e)

MAX_BCRYPT_BYTES = 72


def _to_bytes(s: Union[str, bytes]) -> bytes:
    if isinstance(s, bytes):
        return s
    return s.encode("utf-8")


def _truncate_if_needed(pw_bytes: bytes) -> bytes:
    if len(pw_bytes) > MAX_BCRYPT_BYTES:
        # Bcrypt only uses the first 72 bytes of the password; we truncate explicitly
        logging.warning("Password exceeds %d bytes; truncating before hashing.", MAX_BCRYPT_BYTES)
        return pw_bytes[:MAX_BCRYPT_BYTES]
    return pw_bytes


def get_password_hash(password: str) -> str:
    """Return a bcrypt hash (utf-8 str) for the given password.

    If `bcrypt` isn't available, raise an ImportError with a helpful message.
    Truncates password bytes to 72 bytes before hashing (bcrypt limitation).
    """
    if bcrypt is None:
        raise ImportError("bcrypt library is required for password hashing. Install it with: pip install bcrypt")

    if password is None:
        raise ValueError("password must be a string")

    pw_bytes = _to_bytes(password)
    pw_bytes = _truncate_if_needed(pw_bytes)

    # gensalt default rounds is acceptable (12). If you want to tune, pass rounds to gensalt.
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(pw_bytes, salt)

    # store as utf-8 str for DB compatibility
    return hashed.decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Return True if `plain_password` matches `hashed_password` (both strings).

    Raises ImportError if bcrypt is not installed.
    Handles bcrypt's 72-byte limit by truncating the provided plain password in the same way used when hashing.
    """
    if bcrypt is None:
        raise ImportError("bcrypt library is required for password verification. Install it with: pip install bcrypt")

    if plain_password is None or hashed_password is None:
        return False

    try:
        plain_bytes = _to_bytes(plain_password)
        plain_bytes = _truncate_if_needed(plain_bytes)

        # hashed_password should be stored as utf-8 string; encode to bytes
        hashed_bytes = _to_bytes(hashed_password)

        return bcrypt.checkpw(plain_bytes, hashed_bytes)
    except Exception as e:
        logging.exception("Error while verifying password: %s", e)
        return False
