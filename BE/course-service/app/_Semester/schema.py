from typing import Optional
from pydantic import BaseModel

class SemesterBase(BaseModel):
    description: str

class SemesterCreate(SemesterBase):
    # Inherits 'description: str'
    pass

class SemesterRead(SemesterBase):
    id: int
    
    class Config:
        # Allows Pydantic to read data from the ORM object (like SQLAlchemy)
        from_attributes = True
        
# 3. Used for PATCH requests (partial input)
class SemesterUpdate(BaseModel):
    description: Optional[str] = None