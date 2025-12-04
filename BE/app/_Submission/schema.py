from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class SubmissionBase(BaseModel):
    assignment_id: int
    student_id: int
    submission_text: Optional[str] = None
    file_url: Optional[str] = None


class SubmissionCreate(SubmissionBase):
    pass


class SubmissionGradeUpdate(BaseModel):
    score: float
    feedback: Optional[str] = None


class SubmissionRead(BaseModel):
    submission_id: int
    assignment_id: int
    student_id: int
    student_name: Optional[str] = None
    submission_text: Optional[str] = None
    file_url: Optional[str] = None
    submitted_at: datetime
    score: Optional[float] = None
    feedback: Optional[str] = None
    graded_at: Optional[datetime] = None

    class Config:
        from_attributes = True
