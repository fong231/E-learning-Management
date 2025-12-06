from sqlalchemy import DECIMAL, Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Assignment(Base):
    __tablename__ = 'Assignments'

    assignmentID = Column(
        Integer, 
        ForeignKey('Learning_Content.contentID', ondelete='CASCADE'),
        primary_key=True,
        autoincrement=True
    )

    title = Column(String(255), nullable=False)
    description = Column(Text)
    start_date = Column(DateTime)
    deadline = Column(DateTime, nullable=False)
    late_deadline = Column(DateTime)

    size_limit = Column(DECIMAL(10, 2)) 
    file_format = Column(String(100))

    groupID = Column(
        Integer, 
        ForeignKey('Groups.groupID', ondelete='SET NULL')
    )

    # relationship
    content = relationship(
        "LearningContent", 
        back_populates="assignment", 
        primaryjoin="Assignment.assignmentID == LearningContent.contentID",
        uselist=False # Indicates a one-to-one relationship
    )
    group = relationship(
        "Group", 
        back_populates="assignments"
    )
