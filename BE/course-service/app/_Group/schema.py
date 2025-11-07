from typing import Optional, Literal
from pydantic import BaseModel

class GroupBase(BaseModel):
    courseID: Optional[int] = None

class GroupCreate(GroupBase):
    pass

class GroupRead(GroupBase):
    groupdID: int
    
    class Config:
        from_attributes = True 

class GroupUpdate(BaseModel):
    courseID: Optional[int] = None