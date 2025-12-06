from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal


class AnnoucementBase(BaseModel):
    groupID: Optional[int] = None
    contentID: Optional[int] = None
    
class AnnoucementCreate(AnnoucementBase):
    pass
    
class AnnoucementUpdate(BaseModel):
    groupID: Optional[int] = None
    announcementID: Optional[int] = None

class AnnoucementRead(BaseModel):
    groupID: Optional[int] = None
    announcementID: Optional[int] = None
    
    class Config:
        from_attributes = True


class CommentBase(BaseModel):
    announcement_id: int
    user_id: Optional[int] = None
    content: str


class CommentCreate(CommentBase):
    pass


class CommentRead(BaseModel):
    comment_id: int
    announcement_id: int
    user_id: Optional[int] = None
    user_name: Optional[str] = None
    user_role: Optional[str] = None
    content: str
    created_at: datetime

    class Config:
        from_attributes = True