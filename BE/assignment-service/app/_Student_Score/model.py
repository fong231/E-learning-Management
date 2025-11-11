from sqlalchemy import DECIMAL, TIMESTAMP, Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime, timezone
from ..database import Base

class StudentScore(Base):
    __tablename__ = "Student_Score"

    studentID = Column(Integer, primary_key=True)
    groupID = Column(Integer, primary_key=True)
    quizID = Column(Integer, ForeignKey('Quizzes.quizID', ondelete='CASCADE'), primary_key=True)
    
    score = Column(DECIMAL(5, 2), default=0)
    completed_at = Column(TIMESTAMP, default=datetime.now(timezone.utc))

    quiz = relationship("Quiz", back_populates="student_score")
