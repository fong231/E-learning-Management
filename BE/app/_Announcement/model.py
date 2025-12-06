from sqlalchemy import Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Announcement(Base):
    __tablename__ = "Announcements"

    announcementID = Column(
        Integer,
        ForeignKey('Learning_Content.contentID', ondelete='CASCADE'),
        primary_key=True
    )

    groupID = Column(
        String(255), 
        ForeignKey('Groups.groupID', ondelete='CASCADE'),
        nullable=False)
    
    # relationship
    content = relationship(
        "LearningContent", 
        back_populates="announcement", 
        primaryjoin="Announcement.announcementID == LearningContent.contentID"
    )
    
    group = relationship(
        "Group", 
        back_populates="announcements"
    )
