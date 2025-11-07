from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Learning_Content(Base):
    __tablename__ = "Learning_Content"
    
    contentID = Column(Integer, primary_key=True, index=True)
    
    title = Column(String(255))
    description = Column(Text)
