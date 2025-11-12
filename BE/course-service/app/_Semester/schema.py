from typing import Optional
from pydantic import BaseModel

class SemesterBase(BaseModel):
    description: str

class SemesterCreate(SemesterBase):
    pass

class SemesterRead(SemesterBase):
    semesterID: int
    
    class Config:
        from_attributes = True

class SemesterUpdate(BaseModel):
    description: Optional[str] = None