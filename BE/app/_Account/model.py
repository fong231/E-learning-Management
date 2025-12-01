from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class Account(Base):
    __tablename__ = "Accounts"

    username = Column(String(100), primary_key=True, index=True)
    password = Column(String(255), nullable=False)
    
    customerID = Column(Integer, ForeignKey("Customers.customerID", ondelete='CASCADE'), nullable=False)
    
    # Relationship
    customer = relationship("Customer", back_populates="account")
    
    def verify_password(self, plain_password: str) -> bool:
        """Compares a plain text password with the stored hash."""
        import bcrypt
        try:
            return bcrypt.checkpw(
                plain_password.encode('utf-8'),
                self.password.encode('utf-8')
            )
        except (ValueError, TypeError):
            return False

