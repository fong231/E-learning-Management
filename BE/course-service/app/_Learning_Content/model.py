from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class LearningContent(Base):
    __tablename__ = "Learning_Content"
    
    contentID = Column(Integer, primary_key=True, index=True)
    
    title = Column(String(255))
    description = Column(Text)
    
    # relationship
    material = relationship("Material", back_populates="content")
    resource = relationship("FileImage", back_populates="content")
