from typing import Optional, Literal
from pydantic import BaseModel

### 1. CourseBase: Các trường cơ bản được chia sẻ ###
class CourseBase(BaseModel):
    number_of_sessions: Literal['10', '15']

    description: Optional[str] = None 

    semesterID: Optional[int] = None
    instructorID: Optional[int] = None

class CourseCreate(CourseBase):
    pass

class CourseRead(CourseBase):
    courseID: int
    
    class Config:
        from_attributes = True 

class CourseUpdate(BaseModel):
    number_of_sessions: Optional[str] = None
    description: Optional[str] = None
    semesterID: Optional[int] = None
    instructorID: Optional[int] = None