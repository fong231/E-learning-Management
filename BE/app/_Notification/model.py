from datetime import datetime

from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from ..database import Base


class Notification(Base):
    __tablename__ = "Notifications"

    notificationID = Column(Integer, primary_key=True, index=True)
    type = Column(String(50), nullable=False)
    content = Column(Text, nullable=False)
    status = Column(String(10), nullable=False, default="unread")
    created_at = Column(DateTime, default=datetime.utcnow)
    studentID = Column(Integer, ForeignKey("Students.studentID", ondelete="CASCADE"), nullable=False)

    student = relationship("Student")
