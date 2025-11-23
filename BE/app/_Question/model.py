from sqlalchemy import Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Question(Base):
    __tablename__ = "Questions"

    questionID = Column(Integer, primary_key=True, index=True)
    level = Column(Enum('easy', 'medium', 'hard', name='question_levels'), nullable=False)
    answer = Column(Enum('A', 'B', 'C', 'D', name='answer_options'), nullable=False)
    
    quizID = Column(Integer, ForeignKey('Quizzes.quizID'), ondelete='SET NULL', nullable=True)

    # relationship
    quiz = relationship("Quiz", back_populates="question")