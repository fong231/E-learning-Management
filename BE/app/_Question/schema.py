from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal
import enum

class QuestionLevel(str, enum.Enum):
    easy_question = "easy_question"
    medium_question = "medium_question"
    hard_question = "hard_question"

class AnswerOption(str, enum.Enum):
    A = "A"
    B = "B"
    C = "C"
    D = "D"

class QuestionBase(BaseModel):
    question_text: str
    answer_1: str
    answer_2: str
    answer_3: str
    answer_4: str
    level: QuestionLevel  # 'easy_question', 'medium_question', 'hard_question'
    correct_answer: AnswerOption  # 'A', 'B', 'C', 'D'

class QuestionCreate(QuestionBase):
    quizID: Optional[int] = None

class QuestionUpdate(BaseModel):
    question_text: Optional[str] = None
    answer_1: Optional[str] = None
    answer_2: Optional[str] = None
    answer_3: Optional[str] = None
    answer_4: Optional[str] = None
    level: Optional[QuestionLevel] = None
    correct_answer: Optional[AnswerOption] = None
    quizID: Optional[int] = None

class QuestionRead(QuestionBase):
    questionID: int
    quizID: Optional[int] = None

    class Config:
        from_attributes = True