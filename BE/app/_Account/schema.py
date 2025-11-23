from typing import Optional, Literal
from pydantic import BaseModel, EmailStr
from .._Customer.schema import CustomerCreate, CustomerRead

class AccountBase(BaseModel):
    username: str
    password: str

class AccountCreate(AccountBase, CustomerCreate):
    pass

class AccountRead(AccountBase, CustomerRead):
    accountID: int

    class Config:
        from_attributes = True
    

class AccountUpdate(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    customerID: Optional[int] = None