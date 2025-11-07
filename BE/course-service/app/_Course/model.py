from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Course(Base):
    __tablename__ = "Courses"
    
    courseID = Column(Integer, primary_key=True, index=True)
    
    number_of_sessions = Column(Enum('10', '15'), nullable=False)
    description = Column(Text)
    instructorID = Column(Integer, nullable=True, index=True) # in another service
    
    # Foreign Keys
    semesterID = Column(Integer, ForeignKey('Semesters.semesterID', ondelete="SET NULL"))
    
    # relationship
    semester = relationship("Semester", back_populates="course")
    group = relationship("Group", back_populates="course")
