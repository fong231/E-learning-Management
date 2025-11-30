from typing import Optional, Literal
from pydantic import BaseModel, EmailStr
from .._Customer.schema import CustomerCreate

class AccountBase(BaseModel):
    username: str
    password: str

class AccountCreate(AccountBase, CustomerCreate):
    pass
    

class AccountUpdate(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    customerID: Optional[int] = None
    
class AccountLogin(BaseModel):
    username: str
    password: str