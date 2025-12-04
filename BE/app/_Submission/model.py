from datetime import datetime

from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, Float, String
from sqlalchemy.orm import relationship

from ..database import Base


class Submission(Base):
    __tablename__ = "Submissions"

    submissionID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    assignmentID = Column(Integer, ForeignKey("Assignments.assignmentID", ondelete="CASCADE"), nullable=False)
    studentID = Column(Integer, ForeignKey("Students.studentID", ondelete="CASCADE"), nullable=False)

    submission_text = Column(Text, nullable=True)
    file_url = Column(String(500), nullable=True)

    submitted_at = Column(DateTime, default=datetime.utcnow)
    score = Column(Float, nullable=True)
    feedback = Column(Text, nullable=True)
    graded_at = Column(DateTime, nullable=True)

    assignment = relationship("Assignment")
    student = relationship("Student")
