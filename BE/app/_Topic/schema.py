from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class TopicBase(BaseModel):
    course_id: int
    title: str
    content: str


class TopicCreate(TopicBase):
    creator_id: Optional[int] = None
    creator_name: Optional[str] = None
    creator_role: Optional[str] = None


class TopicUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None


class TopicRead(BaseModel):
    id: int
    course_id: int
    course_name: Optional[str] = None
    creator_id: Optional[int] = None
    creator_name: Optional[str] = None
    creator_role: str
    title: str
    content: str
    view_count: int
    reply_count: int
    created_at: datetime
    updated_at: Optional[datetime] = None


class TopicChatCreate(BaseModel):
    topic_id: int
    user_id: int
    user_role: str
    user_name: Optional[str] = None
    message: str


class TopicChatRead(BaseModel):
    id: int
    topic_id: int
    user_id: int
    user_name: Optional[str] = None
    user_role: str
    message: str
    created_at: datetime
