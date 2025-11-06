from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Semester(Base):
    __tablename__ = "Semesters"
    
    semesterID = Column(Integer, primary_key=True, index=True)
    description = Column(Text)
