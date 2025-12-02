from typing import Optional, Literal
from pydantic import BaseModel, EmailStr
from .._Customer.schema import CustomerCreate, RoleEnum

class AccountCreate(CustomerCreate):
    pass
    

class AccountUpdate(BaseModel):
    fullname: Optional[str] = None
    phone_number : Optional[str] = None
    email : Optional[EmailStr] = None
    avatar: Optional[str] = None
    customerID: Optional[int] = None
    role : Optional[RoleEnum] = RoleEnum.student
    
class AccountLogin(BaseModel):
    email: str
    password: str
    
class AccountPasswordReset(BaseModel):
    current_password : str
    new_password: str