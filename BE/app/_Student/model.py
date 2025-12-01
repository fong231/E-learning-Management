from sqlalchemy import DECIMAL, TIMESTAMP, Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime, timezone
from ..database import Base

class Student(Base):
    __tablename__ = "Students"

    studentID = Column(
        Integer,
        ForeignKey("Customers.customerID", ondelete="CASCADE"),
        primary_key=True,
        index=True
    )

    # Relationship
    customer = relationship("Customer", back_populates="student")