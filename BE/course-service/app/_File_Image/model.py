from sqlalchemy import Column, Integer, String, DateTime, PrimaryKeyConstraint, Text
from sqlalchemy.orm import relationship
from ..database import Base

class FileImage(Base):
    __tablename__ = "Files_Images"
    
    resourceID = Column(Integer, primary_key=True, index=True)
    
    contentID = Column(Integer, primary_key=True)
    
    path = Column(String(500), nullable=False)
    
    upload_at = Column(DateTime)
    
    __table_args__ = (
        PrimaryKeyConstraint('resourceID', 'contentID'),
    )
