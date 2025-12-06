from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal

class StudentScoreBase(BaseModel):
    score: Decimal = Field(default=0, decimal_places=2, max_digits=5)
    completed_at: Optional[datetime] = None
    
    # Numeric(10, 2) maps to Decimal
    size_limit: Optional[Decimal] = None 
    
    file_format: Optional[str] = None

    groupID: Optional[int] = None
    contentID: Optional[int] = None
    
class StudentScoreCreate(StudentScoreBase):
    studentID: int
    groupID: int
    quizID: int

    completed_at: Optional[datetime] = None
    
class StudentScoreUpdate(BaseModel):
    score: Optional[Decimal] = Field(default=None, decimal_places=2, max_digits=5)

class StudentScoreRead(StudentScoreBase):
    studentID: int
    groupID: int
    quizID: int
    score: Decimal = Field(decimal_places=2, max_digits=5)
    completed_at: datetime
    
    class Config:
        from_attributes = True