from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from ..database import Base


class Topic(Base):
    __tablename__ = "Topics"

    topicID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    courseID = Column(Integer, ForeignKey("Courses.courseID", ondelete="CASCADE"), nullable=False)

    course = relationship("Course")
    chats = relationship("TopicChat", back_populates="topic", cascade="all, delete-orphan")
    files = relationship("TopicFile", back_populates="topic", cascade="all, delete-orphan")


class TopicChat(Base):
    __tablename__ = "Topic_Chats"

    messageID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    message = Column(Text, nullable=False)
    topicID = Column(Integer, ForeignKey("Topics.topicID", ondelete="CASCADE"), nullable=False)
    studentID = Column(Integer, ForeignKey("Students.studentID", ondelete="SET NULL"))

    topic = relationship("Topic", back_populates="chats")
    student = relationship("Student")


class TopicFile(Base):
    __tablename__ = "Topic_Files"

    fileID = Column(Integer, primary_key=True, index=True, autoincrement=True)
    path = Column(String(500), nullable=False)
    topicID = Column(Integer, ForeignKey("Topics.topicID", ondelete="CASCADE"), nullable=False)

    topic = relationship("Topic", back_populates="files")
