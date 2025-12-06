from datetime import datetime

from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from ..database import Base


class Message(Base):
    __tablename__ = "Messages"

    messageID = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)
    senderID = Column(Integer, ForeignKey("Customers.customerID", ondelete="CASCADE"), nullable=False)
    receiverID = Column(Integer, ForeignKey("Customers.customerID", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    sender = relationship("Customer", foreign_keys=[senderID])
    receiver = relationship("Customer", foreign_keys=[receiverID])


class MessageRead(Base):
    __tablename__ = "Message_Read"

    messageID = Column(Integer, ForeignKey("Messages.messageID", ondelete="CASCADE"), primary_key=True)
    userID = Column(Integer, ForeignKey("Customers.customerID", ondelete="CASCADE"), primary_key=True)
