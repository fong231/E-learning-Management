from sqlalchemy import Column, Integer, String, DateTime, PrimaryKeyConstraint, Text, ForeignKey
from sqlalchemy.orm import relationship
from ..database import Base

class FileImage(Base):
    __tablename__ = "Files_Images"
    
    resourceID = Column(Integer, index=True, primary_key=True)
    
    contentID = Column(Integer, ForeignKey('Learning_Content.contentID', ondelete="CASCADE"), nullable=False)
    
    path = Column(String(500), nullable=False)
    
    uploaded_at = Column(DateTime)
    uploaded_by = Column(Integer, ForeignKey('Customers.customerID', ondelete="CASCADE"), nullable=False)
    
    # relationship
    content = relationship("LearningContent", back_populates="resource")

