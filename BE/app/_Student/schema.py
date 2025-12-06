from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

class StudentCreate(BaseModel):
    studentID: int = Field(..., description="The ID of the student, which must be an existing customerID.")
    
class Student(BaseModel):
    studentID: int = Field(..., description="The unique ID of the student.")

    class Config:
        from_attributes = True
        
class StudentOutput(BaseModel):
    id: int = Field(..., alias="customerID")
    fullname: str
    email: str
    avatar: Optional[str] = None
    phone_number: Optional[str] = None
    address: Optional[str] = None
    role: str
    
    groupId: Optional[int] = None
    groupName: Optional[str] = None

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)