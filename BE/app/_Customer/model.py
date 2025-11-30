from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Customer(Base):
    __tablename__ = "Customers"
    
    customerID = Column(Integer, primary_key=True, index=True)
    
    phone_number = Column(String(20))
    email = Column(String(255), nullable=False, unique=True)
    avatar = Column(String(500))
    fullname = Column(String(255), nullable=False)
    role = Column(Enum("student", "instructor", name="customer_roles"), nullable=False, default="student")
    
    # Relationship
    account = relationship("Account", back_populates="customer")

