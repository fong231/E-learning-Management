import bcrypt
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Customer import model as CustomerModel
from .._Authenticate.authenticate import check_password_complexity

router = APIRouter(
    prefix="/accounts",
    tags=["Accounts"],
)

def hash_password(password: str) -> str:
    hashed_bytes = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed_bytes.decode('utf-8')

# update account password
@router.patch("/{account_id}/reset-password")
def reset_password(
    account_id: int, 
    account_data: schema.AccountPasswordReset, 
    db: Session = Depends(get_db)
):
    if not db.get(CustomerModel.Customer, account_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")

    db_account = db.query(model.Account).filter(
        model.Account.customerID == account_id
    ).first()
    
    if not db_account:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found for this customer.")

    if not db_account.verify_password(account_data.current_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Incorrect current password."
        )
        
    is_valid, detail = check_password_complexity(account_data.new_password)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "Password does not meet complexity requirements", "details": detail}
        )

    hashed_password = hash_password(account_data.new_password)

    db_account.password = hashed_password
    
    db.commit()
    db.refresh(db_account)

    return {"message": "Successful update password"}
    
# delete account
@router.delete("/{customer_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(customer_id : int, db : Session = Depends(get_db)):
    db_customer = db.query(CustomerModel.Customer).filter(CustomerModel.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    
    db.delete(db_customer)
    db.commit()
    
    return