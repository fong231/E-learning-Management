from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base
    
### GROUP ###
class Group(Base):
    __tablename__ = "Groups"
    
    groupID = Column(String, primary_key=True, index=True)
    
    number_of_sessions = Column(Enum('10', '15'), nullable=False)
    description = Column(Text)
    instructorID = Column(String, nullable=True, index=True) # in another service
    
    # Foreign Keys
    courseID = Column(Integer, ForeignKey('Courses.courseID', ondelete="SET NULL"))
    
    # relationship
    course = relationship("Course", back_populates="groups")
