from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal

class AssignmentBase(BaseModel):
    start_date: Optional[datetime] = None
    deadline: datetime
    late_deadline: Optional[datetime] = None
    
    # Numeric(10, 2) maps to Decimal
    size_limit: Optional[Decimal] = None 
    
    file_format: Optional[str] = None

    groupID: Optional[int] = None
    contentID: Optional[int] = None
    
class AssignmentCreate(AssignmentBase):
    pass
    
class AssignmentUpdate(BaseModel):
    start_date: Optional[datetime] = None
    deadline: Optional[datetime] = None
    late_deadline: Optional[datetime] = None
    size_limit: Optional[Decimal] = None
    file_format: Optional[str] = None
    groupID: Optional[int] = None
    contentID: Optional[int] = None

class AssignmentRead(AssignmentBase):
    
    class Config:
        from_attributes = True