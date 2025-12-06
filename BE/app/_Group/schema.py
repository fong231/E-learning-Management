from typing import List, Optional, Literal
from pydantic import BaseModel, ConfigDict
from .._Student.schema import StudentOutput

class GroupBase(BaseModel):
    courseID: Optional[int] = None

class GroupCreate(GroupBase):
    pass

class GroupRead(GroupBase):
    groupID: int
    
    class Config:
        from_attributes = True 

class GroupUpdate(BaseModel):
    courseID: Optional[int] = None
    
class GroupOutput(BaseModel):
    id: int
    courseId: int
    courseName: str
    groupName: str
    students: List[StudentOutput]
    
    model_config = ConfigDict()