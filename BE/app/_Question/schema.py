from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal
import enum

class QuestionLevel(str, enum.Enum):
    easy = "easy"
    medium = "medium"
    hard = "hard"

class AnswerOption(str, enum.Enum):
    A = "A"
    B = "B"
    C = "C"
    D = "D"

class QuestionBase(BaseModel):
    level : QuestionLevel  # 'easy', 'medium', 'hard'
    answer : AnswerOption  # 'A', 'B', 'C', 'D'
    
class QuestionCreate(QuestionBase):
    quizID: Optional[int] = None
    
class QuestionUpdate(BaseModel):
    level: Optional[QuestionLevel] = None
    answer: Optional[AnswerOption] = None
    quizID: Optional[int] = None

class QuestionRead(QuestionBase):
    questionID: int
    quizID: Optional[int] = None
    
    class Config:
        from_attributes = True