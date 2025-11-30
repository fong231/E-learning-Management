import bcrypt
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Customer import model as CustomerModel
from .._Customer.customer import create_customer

router = APIRouter(
    prefix="/accounts",
    tags=["Accounts"],
)

def hash_password(password: str) -> str:
    hashed_bytes = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed_bytes.decode('utf-8')

# update account password
@router.patch("/reset-password", response_model=schema.AccountRead)
def reset_password(account_data: schema.AccountUpdate, db : Session = Depends(get_db)):
    # TODO add email verification step
    if account_data.customerID:
        customer = db.query(CustomerModel.Customer).filter(
            CustomerModel.Customer.customerID == account_data.customerID
        ).first()
        if not customer:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    db_account = db.query(model.Account).filter(model.Account.customerID == account_data.customerID).first()
    
    if not db_account:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    
    update_data = account_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_account, key, value)

    db.commit()
    db.refresh(db_account)
    
    return db_account
    
# delete account
@router.delete("/{customer_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(customer_id : int, db : Session = Depends(get_db)):
    db_customer = db.query(CustomerModel.Customer).filter(CustomerModel.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    
    db.delete(db_customer)
    db.commit()
    
    return

# helper function
def check_service_availability(name: str, url: str) -> bool:
    """Requests the endpoint to check if the external item exists."""
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return True
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == status.HTTP_404_NOT_FOUND:
            return False 
        raise
    except requests.RequestException as e:
        raise RuntimeError(f"External service '{name}' is unavailable: {str(e)}")