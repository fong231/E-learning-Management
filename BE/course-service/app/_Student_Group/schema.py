from typing import Optional
from pydantic import BaseModel

class StudentGroupAssociationBase(BaseModel):
    studentID: int

class StudentGroupAssociationCreate(StudentGroupAssociationBase):
    pass

class StudentGroupAssociationRead(StudentGroupAssociationBase):
    class Config:
        from_attributes = True