# app/auth.py
from datetime import datetime, timedelta, timezone
from typing import Annotated, Optional
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from .._Authenticate.model import TokenData
from sqlalchemy.orm import Session
from .._Account import model as AccountModel
from ..config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES
from ..database import get_db

# Define the OAuth2 scheme (FastAPI standard for login)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Generates the JWT."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str):
    """Decodes and validates the JWT."""
    try:
        # 1. Decode the token using the secret key
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # 2. Extract the user identifier
        username: int = payload.get("sub")
        if username is None:
            raise JWTError("Invalid credentials", status_code=status.HTTP_401_UNAUTHORIZED)
            
        return payload
        
    except JWTError as e:
        # Handles expiration and invalid signature errors
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_current_active_user(token: Annotated[str, Depends(oauth2_scheme)], db: Session = Depends(get_db)):
    """
    Decodes the JWT token to get the current user.
    This function acts as a dependency for protected endpoints.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # Decode the token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    
    # Get user from the 'database'
    user = db.query(AccountModel.Account).filter(AccountModel.Account.username == token_data.username).first()
    if user is None:
        raise credentials_exception
    # if user.disabled:
    #     raise HTTPException(status_code=400, detail="Inactive user")
    
    return user
        
