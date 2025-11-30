from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Instructor(Base):
    __tablename__ = "Instructors"

    instructorID = Column(
        Integer,
        ForeignKey("Customers.customerID", ondelete="CASCADE"),
        primary_key=True,
        index=True
    )

    # relationship
    customer = relationship("Customer", back_populates="instructor")
