from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Material(Base):
    __tablename__ = "Materials"
    
    materialID = Column(
        Integer,
        ForeignKey('Learning_Content.contentID', ondelete="CASCADE"), # foreign to content ID
        primary_key=True, index=True)
    
    title = Column(String(255))
    description = Column(Text)
    
    # relationship
    content = relationship("LearningContent", back_populates="material")
