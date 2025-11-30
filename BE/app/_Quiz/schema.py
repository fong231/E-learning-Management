from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal

class QuizBase(BaseModel):
    duration : int = Field(default=1, ge=0)  # duration in minutes
    open_time : datetime
    close_time : datetime
    easy_questions : int = Field(default=0, ge=0)
    medium_questions : int = Field(default=0, ge=0)
    hard_questions : int = Field(default=0, ge=0)
    number_of_attempts : int = Field(default=1, ge=1)
    
class QuizCreate(QuizBase):
    pass
    
class QuizUpdate(BaseModel):
    duration : Optional[int] = Field(default=None, ge=0)  # duration in minutes
    open_time : Optional[datetime] = None
    close_time : Optional[datetime] = None
    easy_questions : Optional[int] = Field(default=None, ge=0)
    medium_questions : Optional[int] = Field(default=None, ge=0)
    hard_questions : Optional[int] = Field(default=None, ge=0)
    number_of_attempts : Optional[int] = Field(default=None, ge=1)

class QuizRead(QuizBase):
    
    class Config:
        from_attributes = True