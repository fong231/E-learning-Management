from datetime import datetime

from pydantic import BaseModel


class NotificationRead(BaseModel):
    notification_id: int
    student_id: int
    type: str
    title: str
    content: str
    is_read: bool
    created_at: datetime
