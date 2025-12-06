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


class Comment(Base):
    __tablename__ = "Comments"

    commentID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    message = Column(Text, nullable=False)
    ownerID = Column(Integer, ForeignKey('Customers.customerID', ondelete='SET NULL'), nullable=True)
    announcementID = Column(Integer, ForeignKey('Announcements.announcementID', ondelete='CASCADE'), nullable=False)

    owner = relationship("Customer")
    announcement = relationship("Announcement")
