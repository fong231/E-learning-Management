from datetime import datetime
from typing import Dict, Optional

from pydantic import BaseModel


class QuizAttemptCreate(BaseModel):
    quiz_id: int
    student_id: int


class QuizAttemptSubmit(BaseModel):
    answers: Dict[int, str]


class QuizAttemptRead(BaseModel):
    attempt_id: int
    quiz_id: int
    student_id: int
    student_name: Optional[str] = None
    started_at: datetime
    completed_at: Optional[datetime] = None
    score: Optional[float] = None
    attempt_number: int
