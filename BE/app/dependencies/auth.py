# app/auth.py
from datetime import datetime, timedelta, timezone
from typing import Annotated, Optional
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, Header, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES
from ..database import get_db

security = HTTPBearer()

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None
    

class CustomJWTError(Exception):
    def __init__(self, detail: str, status_code: int):
        self.detail = detail
        self.status_code = status_code

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
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # 2. Extract the user identifier
        email: str = payload.get("sub")
        # session_id_in_jwt = payload.get("sid")
        
        if email is None:
            raise CustomJWTError("Token is missing the 'sub' claim (email)", 
                                 status_code=status.HTTP_401_UNAUTHORIZED)

        return payload
        
    except JWTError as e:
        raise CustomJWTError(f"Token validation failed: {str(e)}", 
                             status_code=status.HTTP_401_UNAUTHORIZED)
    
    except CustomJWTError as e:
        raise e
    
async def get_raw_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    return credentials.credentials  

async def get_current_active_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)):
    from .._Authenticate.authenticate import validate_token
    
    token = credentials.credentials
    
    auth_record = await validate_token(token, db)
    
    if not auth_record:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    
    return auth_record
    # return


def get_token_from_header(authorization: Annotated[Optional[str], Header()] = None) -> str:
    """Extracts the token string from the 'Authorization: Bearer <token>' header."""
    if authorization is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing"
        )
    
    parts = authorization.split()
    if parts[0].lower() != "bearer" or len(parts) != 2:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token format (Expected: Bearer <token>)"
        )
    return parts[1]
