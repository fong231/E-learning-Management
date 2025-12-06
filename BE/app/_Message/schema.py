from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class MessageBase(BaseModel):
    sender_id: int
    receiver_id: int
    content: str
    sender_role: Optional[str] = None
    receiver_role: Optional[str] = None


class MessageCreate(MessageBase):
    pass


class MessageRead(BaseModel):
    message_id: int
    sender_id: int
    sender_name: Optional[str] = None
    sender_role: str
    receiver_id: int
    receiver_name: Optional[str] = None
    receiver_role: str
    content: str
    is_read: bool
    sent_at: datetime
