from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from ..config import INSTRUCTOR_BASE_URL

router = APIRouter(
    prefix="/customers",
    tags=["Customers"],
)

def create_customer(customer: schema.CustomerCreate, db: Session):
    email = customer.email
    email_exist = db.query(model.Customer).filter(model.Customer.email == email).first()
    if email_exist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Customer with email '{email}' already exists."
        )
    
    db_customer = model.Customer(**customer.model_dump())
    
    db.add(db_customer)
    db.commit()
    return db_customer

# create customer
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(customer: schema.CustomerCreate, db: Session = Depends(get_db)):

    create_customer(customer, db)
    
    return {"message": "Customer created successfully"}

# read customer
@router.get("/{customer_id}", response_model=schema.CustomerRead)
def read(customer_id : int, db : Session = Depends(get_db)):
    customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    return customer

# update customer
@router.patch("/{customer_id}", response_model=schema.CustomerRead)
def update(customer_id : int, customer_data: schema.CustomerUpdate, db : Session = Depends(get_db)):
    db_customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    email = db_customer.email
    email_exist = db.query(model.Customer).filter(model.Customer.email == email).first()
    if email_exist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Customer with email '{email}' already exists."
        )
    
    update_data = customer_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_customer, key, value)

    db.commit()
    db.refresh(db_customer)
    
    return db_customer
    
# delete customer
@router.delete("/{customer_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(customer_id : int, db : Session = Depends(get_db)):
    db_customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
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