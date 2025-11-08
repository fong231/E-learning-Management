from fastapi import Depends
from typing import Annotated
from ..config import AUTH_REQUIRED
from .auth import get_current_active_user
from .._Account.schema import AccountBase as User

# Define a placeholder user that matches the structure of User model
UNAUTHENTICATED_USER = User(
    username="guest_unauthenticated",
    password="guest_password",
)

async def conditional_get_current_user(
    # Always call the full verification dependency, but only use its result if needed.
    # Note: If AUTH_REQUIRED is True, the function below will still raise 401 if token is bad.
    current_user: Annotated[User, Depends(get_current_active_user)]
) -> User:
    """
    Conditionally runs authentication based on the AUTH_REQUIRED setting.
    If AUTH_REQUIRED is True, returns the verified user.
    If AUTH_REQUIRED is False, returns a placeholder user.
    """
    if AUTH_REQUIRED:
        # Authentication is ON. The upstream dependency (get_current_active_user)
        # has already raised an exception if the token was invalid/missing.
        # If we reach here, the user is authenticated.
        return current_user
    else:
        # Authentication is OFF. Bypass the verified user and return a guest/placeholder.
        return UNAUTHENTICATED_USER
    
