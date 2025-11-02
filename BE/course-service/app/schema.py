from pydantic import BaseModel
from datetime import datetime

class EventCreate(BaseModel):
    name: str
    description: str
    start_time: datetime
    end_time: datetime

class EventRead(EventCreate):
    id: str

    class Config:
        orm_mode = True
