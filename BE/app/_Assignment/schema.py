from pydantic import BaseModel
from typing import Optional, List

from datetime import datetime
from decimal import Decimal

class AssignmentBase(BaseModel):
    title : str
    description : Optional[str] = None
    start_date: Optional[datetime] = None
    deadline: datetime
    late_deadline: Optional[datetime] = None
    
    # Numeric(10, 2) maps to Decimal
    size_limit: Optional[Decimal] = None 
    
    file_format: Optional[str] = None
    
class AssignmentCreate(AssignmentBase):
    course_id: int
    group_id: int
    files_url: Optional[List[str]] = None
    
class AssignmentUpdate(BaseModel):
    title : str
    description : Optional[str] = None
    start_date: Optional[datetime] = None
    deadline: Optional[datetime] = None
    late_deadline: Optional[datetime] = None
    size_limit: Optional[Decimal] = None
    file_format: Optional[str] = None
    groupID: Optional[int] = None
    contentID: Optional[int] = None

class AssignmentRead(AssignmentBase):
    assignmentID : int
    groupID: int
    class Config:
        from_attributes = True