from datetime import timedelta
import re
from typing import Any, Dict, Tuple
import bcrypt
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Customer import model as CustomerModel
from .._Customer import schema as CustomerSchema
from .._Customer.customer import create_customer
from ..dependencies.auth import CustomJWTError, create_access_token, decode_access_token, get_token_from_header
from ..config import ACCESS_TOKEN_EXPIRE_MINUTES

MIN_LENGTH = 8

router = APIRouter(
    prefix="/auth",
    tags=["Authenticate"],
)
async def validate_token(token : str = Depends(get_token_from_header), db: Session = Depends(get_db)): # <== THÊM DB
    try:
        payload = decode_access_token(token)
        username = payload.get("sub")
        # session_id_in_jwt = payload.get("sid")

        if not username:
            raise CustomJWTError(status_code=401, detail="Invalid token structure")

        # session_exists = db.query(session_model.Session).filter(
        #     session_model.Session.session_id == session_id_in_jwt,
        #     session_model.Session.user_id == account_id
        # ).first()

        # if not session_exists:
        #     raise CustomJWTError(status_code=401, detail="Token revoked (Session terminated)")

        return model.TokenData(username=username)
        
    except CustomJWTError as e:
        raise HTTPException(
            status_code=e.status_code,
            detail=e.detail,
            headers={"X-Auth-Failed": "Token rejected"} 
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

# update account password
@router.patch("/{customer_id}/change-password")
def reset_password(
    customer_id: int, 
    account_data: schema.AccountPasswordReset, 
    db: Session = Depends(get_db)
):
    if not db.get(CustomerModel.Customer, customer_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")

    db_customer = db.query(CustomerModel.Customer).filter(
        CustomerModel.Customer.customerID == customer_id
    ).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found for this customer.")

    if not db_customer.verify_password(account_data.current_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Current password is incorrect"
        )
        
    # is_valid, detail = check_password_complexity(account_data.new_password)
    # if not is_valid:
    #     raise HTTPException(
    #         status_code=status.HTTP_400_BAD_REQUEST,
    #         detail={"error": "Password does not meet complexity requirements", "details": detail}
    #     )

    hashed_password = hash_password(account_data.new_password)

    db_customer.password = hashed_password
    
    db.commit()
    db.refresh(db_customer)

    return {"message": "Password changed successfully"}    

# register account
@router.post("/register", status_code=status.HTTP_201_CREATED, response_model=CustomerSchema.TokenWithCustomer)
def register(customer: schema.AccountCreate, db: Session = Depends(get_db)):
    username_exist = db.query(CustomerModel.Customer).filter(
        CustomerModel.Customer.fullname == customer.email
    ).first()
    if username_exist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Customer with this email already exist"
        )
    
    # is_valid, detail = check_password_complexity(account.password)
    # if not is_valid:
    #     raise HTTPException(
    #         status_code=status.HTTP_400_BAD_REQUEST,
    #         detail={"error": "Password does not meet complexity requirements", "details": detail}
    #     )
        
    hashed_password = hash_password(customer.password)

    customer_data = schema.CustomerCreate(
        fullname=customer.fullname,
        email=customer.email,
        avatar=customer.avatar,
        phone_number=customer.phone_number,
        password=hashed_password
    )
    customer = create_customer(customer_data, db)
    
    if not customer:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Can't create customer")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": customer.fullname}, expires_delta=access_token_expires
    )

    return {
        "token": access_token, 
        "token_type": "bearer",
        "customer" : customer}

# login account
@router.post("/login", response_model=CustomerSchema.TokenWithCustomer)
def login(form_data : schema.AccountLogin,
        db: Session = Depends(get_db)):

    user = db.query(CustomerModel.Customer).filter(
        CustomerModel.Customer.fullname == form_data.username
    ).first()
    
    if not user or not user.verify_password(form_data.password):
        # print(form_data.email, form_data.password)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.fullname}, expires_delta=access_token_expires
    )
    
    return {
        "token": access_token,
        "token_type": "bearer",
        "customer" : user}
    
@router.get("/me", response_model=CustomerSchema.CustomerRead)
def get_current_user(token : str = Depends(get_token_from_header), db : Session = Depends(get_db)):
    """
        input: token in header,
        output: customer data,
        you should test this in postman for header input
    """
    
    payload = decode_access_token(token)
    email = payload.get("sub")
    
    customer = db.query(CustomerModel.Customer).filter(
        CustomerModel.Customer.fullname == email
    ).first()
    
    if not customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="error get current user data")
    
    return customer