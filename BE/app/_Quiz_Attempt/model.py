from datetime import datetime

from sqlalchemy import Column, Integer, DateTime, Float, ForeignKey
from sqlalchemy.orm import relationship

from ..database import Base


class QuizAttempt(Base):
    __tablename__ = "Quiz_Attempts"

    attemptID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    quizID = Column(Integer, ForeignKey("Quizzes.quizID", ondelete="CASCADE"), nullable=False)
    studentID = Column(Integer, ForeignKey("Students.studentID", ondelete="CASCADE"), nullable=False)

    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    score = Column(Float, nullable=True)
    attempt_number = Column(Integer, default=1)

    quiz = relationship("Quiz")
    student = relationship("Student")
