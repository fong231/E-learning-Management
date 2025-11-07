from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Group(Base):
    __tablename__ = "Groups"
    
    groupID = Column(Integer, primary_key=True, index=True)
    
    number_of_sessions = Column(Enum('10', '15'), nullable=False)
    description = Column(Text)
    instructorID = Column(Integer, nullable=True, index=True) # in another service
    
    # Foreign Keys
    courseID = Column(Integer, ForeignKey('Courses.courseID', ondelete="SET NULL"))
    
    # relationship
    course = relationship("Course", back_populates="group")
    student_association = relationship("StudentGroupAssociation", back_populates="group")
