from typing import Optional, Literal
from pydantic import BaseModel

class Learning_ContentBase(BaseModel):
    assignmentID : int 
    title: Optional[str] = None
    description: Optional[str] = None
    groupID : int

class Learning_ContentCreate(Learning_ContentBase):
    pass

class Learning_ContentRead(Learning_ContentBase):
    assignmentID: int
    
    class Config:
        from_attributes = True 

class Learning_ContentUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None