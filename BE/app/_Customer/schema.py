from typing import Optional, Literal
from pydantic import BaseModel, EmailStr
import enum

class RoleEnum(str, enum.Enum):
    student = "student"
    instructor = "instructor"

class CustomerBase(BaseModel):
    phone_number : Optional[str] = None
    email : EmailStr
    avatar : Optional[str] = None
    fullname : str

class CustomerCreate(CustomerBase):
    password : str
    pass

class CustomerRead(CustomerBase):
    customerID: int
    role : RoleEnum
    
    class Config:
        from_attributes = True 

class CustomerUpdate(BaseModel):
    phone_number : Optional[str] = None
    email : Optional[EmailStr] = None
    avatar : Optional[str] = None
    fullname : Optional[str] = None
    role : Optional[RoleEnum] = None
    
class TokenWithCustomer(BaseModel):
    token: str
    token_type: str
    customer: CustomerRead