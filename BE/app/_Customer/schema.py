from typing import Optional, Literal
from fastapi import Form
from pydantic import BaseModel, EmailStr
import enum

class RoleEnum(str, enum.Enum):
    student = "student"
    instructor = "instructor"

class CustomerBase(BaseModel):
    phone_number : Optional[str] = None
    email : EmailStr
    fullname : str

class CustomerCreate(CustomerBase):
    password : str
    pass

class CustomerRead(CustomerBase):
    customerID: int
    avatar : Optional[str] = None
    role : RoleEnum
    
    class Config:
        from_attributes = True 

# class CustomerUpdate(BaseModel):
#     phone_number : Optional[str] = None
#     email : Optional[EmailStr] = None
#     # avatar : Optional[str] = None
#     fullname : Optional[str] = None
#     role : Optional[RoleEnum] = None
    
class TokenWithCustomer(BaseModel):
    token: str
    token_type: str
    customer: CustomerRead

class CustomerUpdate(BaseModel):
    fullname: Optional[str] = None
    email: Optional[EmailStr] = None
    phone_number : Optional[str] = None
    role : Optional[RoleEnum] = None

    @classmethod
    def as_form(
        cls,
        fullname: Optional[str] = Form(None),
        email: Optional[EmailStr] = Form(None),
        phone_number: Optional[str] = Form(None),
        role: Optional[RoleEnum] = Form(None),
    ):
        return cls(
            fullname=fullname,
            email=email,
            phone_number = phone_number,
            role = role
        )