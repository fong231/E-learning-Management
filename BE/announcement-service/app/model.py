from sqlalchemy import Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from .database import Base

class Annoucement(Base):
    __tablename__ = "Annoucements"

    annoucementID = Column(Integer, primary_key=True, index=True)

    groupID = Column(String, nullable=False)
    contentID = Column(String, nullable=False)
