from sqlalchemy import Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Quiz(Base):
    __tablename__ = "Quizzes"

    quizID = Column(Integer, primary_key=True, index=True)
    
    duration = Column(Integer)
    open_time = Column(DateTime)
    close_time = Column(DateTime)
    easy_questions = Column(Integer, default=0)
    medium_questions = Column(Integer, default=0)
    hard_questions = Column(Integer, default=0)
    number_of_attempts = Column(Integer, default=1)
    
    # relationship
    question = relationship("Question", back_populates="quiz")

