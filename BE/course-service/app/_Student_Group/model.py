from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class StudentGroupAssociation(Base):
    __tablename__ = "Student_Group"
    
    studentID = Column(Integer, primary_key=True) #external data get from another service
    
    # Foreign Keys
    groupID = Column(Integer, ForeignKey('Groups.groupID', ondelete='CASCADE'), primary_key=True)
    
    # Relationship
    group = relationship("Group", back_populates="student_associations")
