from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class FileImageBase(BaseModel):
    path: str

    contentID: int

    uploaded_at: Optional[datetime] = None
    
class FileImageCreate(FileImageBase):
    path: str
    contentID: str
    
class FileImageUpdate(BaseModel):
    path: Optional[str] = None

class FileImageRead(FileImageBase):
    resourceID: int

    uploaded_at: datetime 
    
    class Config:
        from_attributes = True