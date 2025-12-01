from typing import Optional, Literal
from pydantic import BaseModel, EmailStr, model_validator
from .._Customer.schema import CustomerCreate, CustomerRead

class AccountBase(BaseModel):
    username: str
    

class AccountCreate(AccountBase, CustomerCreate):
    password: str
    pass

class AccountRead(BaseModel):
    username: str

    customerID: int
    phone_number : Optional[str] = None
    email : EmailStr
    avatar : Optional[str] = None
    fullname : str

    class Config:
        from_attributes = True

    @model_validator(mode='before')
    @classmethod
    def pull_customer_details(cls, data):
        if hasattr(data, 'customer') and data.customer:
            combined_data = data.__dict__.copy()
            combined_data.update(data.customer.__dict__)
            return combined_data
            
        return data
    

class AccountUpdate(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    customerID: Optional[int] = None
    
class AccountPasswordReset(BaseModel):
    current_password : str
    new_password: str