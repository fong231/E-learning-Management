from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class TicketBase(BaseModel):
    event_id: str
    user_id: str


class TicketCreate(TicketBase):
    pass


class TicketRead(TicketBase):
    id: str
    qr_code: str
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
