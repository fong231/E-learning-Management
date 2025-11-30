from typing import Optional, Literal
from pydantic import BaseModel, EmailStr
import enum

class RoleEnum(str, enum.Enum):
    student = "student"
    instructor = "instructor"

class CustomerBase(BaseModel):
    phone_number : Optional[str] = None
    email : EmailStr
    avatar_url : Optional[str] = None
    full_name : str

class CustomerCreate(CustomerBase):
    pass

class CustomerRead(CustomerBase):
    customerID: int
    
    class Config:
        from_attributes = True 

class CustomerUpdate(BaseModel):
    phone_number : Optional[str] = None
    email : Optional[EmailStr] = None
    avatar_url : Optional[str] = None
    full_name : Optional[str] = None
    role : Optional[RoleEnum] = None