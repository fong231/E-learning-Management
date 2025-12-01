from datetime import timedelta
import re
from typing import Any, Dict, Tuple
import bcrypt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Account import model as AccountModel
from .._Customer.customer import create_customer
from ..dependencies.auth import create_access_token, decode_access_token
from ..config import ACCESS_TOKEN_EXPIRE_MINUTES

MIN_LENGTH = 8

router = APIRouter(
    prefix="/auth",
    tags=["Authenticate"],
)

def hash_password(password: str) -> str:
    hashed_bytes = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed_bytes.decode('utf-8')

def check_password_complexity(password: str) -> Tuple[bool, Dict[str, Any]]:
    """
    Checks the complexity of a given password against several security criteria.

    Criteria checked:
    1. Minimum length (set to MIN_LENGTH)
    2. Contains at least one uppercase letter (A-Z)
    3. Contains at least one lowercase letter (a-z)
    4. Contains at least one digit (0-9)
    5. Contains at least one special character (Punctuation/Symbols)

    Args:
        password (str): The password string to check.

    Returns:
        Tuple[bool, Dict[str, Any]]: 
        - bool: True if all criteria are met, False otherwise.
        - Dict: Detailed status of each criterion check.
    """
    
    # 1. Define criteria checks using regular expressions
    criteria = {
        "min_length": (len(password) >= MIN_LENGTH, f"Length must be at least {MIN_LENGTH} characters"),
        "uppercase": (re.search(r"[A-Z]", password) is not None, "Must contain at least one uppercase letter"),
        "lowercase": (re.search(r"[a-z]", password) is not None, "Must contain at least one lowercase letter"),
        "digit": (re.search(r"\d", password) is not None, "Must contain at least one digit (0-9)"),
        "special_char": (re.search(r"[!@#$%^&*()\-_+=[\]{}|;:,.<>?]", password) is not None, "Must contain at least one special character"),
    }
    
    # 2. Compile the results
    results = {}
    is_complex = True
    
    for key, (passed, message) in criteria.items():
        results[key] = {
            "passed": passed,
            "message": message
        }
        if not passed:
            is_complex = False
            
    return is_complex, results
    

# register account
@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(account: schema.AccountCreate, db: Session = Depends(get_db)):
    customer_data = schema.CustomerCreate(
        fullname=account.fullname,
        email=account.email,
        avatar=account.avatar,
        phone_number=account.phone_number
    )
    customer = create_customer(customer_data, db)
    db.flush()
    
    is_valid, detail = check_password_complexity(account.password)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "Password does not meet complexity requirements", "details": detail}
        )
    
    hashed_password = hash_password(account.password)
    username_exist = db.query(AccountModel.Account).filter(
        AccountModel.Account.username == account.username
    ).first()
    if username_exist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Account with username '{account.username}' already exists."
        )
    
    db_account = AccountModel.Account(
        username=account.username,
        password=hashed_password,
        customerID=customer.customerID
    )
    
    db.add(db_account)
    db.commit()
    db.refresh(db_account)
    return {"message": "Account registered successfully"}

# login account
@router.post("/login", response_model=model.Token)
def login(form_data : schema.AccountLogin,
        db: Session = Depends(get_db)):

    user = db.query(AccountModel.Account).filter(
        AccountModel.Account.username == form_data.username
    ).first()
    
    if not user or not user.verify_password(form_data.password):
        print(form_data.username, form_data.password)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}