from sqlalchemy import Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Assignment(Base):
    __tablename__ = "Assignments"

    assignmentID = Column(Integer, primary_key=True, index=True)

    start_date = Column(DateTime)
    deadline = Column(DateTime, nullable=False)
    late_deadline = Column(DateTime)

    size_limit = Column(Numeric(10, 2)) 

    file_format = Column(String(100))
    
    # external
    groupID = Column(Integer, nullable=True, index=True) # in another service - refer to course service
    contentID = Column(Integer, nullable=True, index=True) # in another service - refer to course service
