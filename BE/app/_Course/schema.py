from typing import Optional, Literal
from pydantic import BaseModel

class CourseBase(BaseModel):
    number_of_sessions: Literal['10', '15']
    course_name: str
    description: Optional[str] = None 
    semesterID: int
    instructorID: Optional[int] = None

class CourseCreate(CourseBase):
    pass

class CourseRead(CourseBase):
    courseID: int
    
    class Config:
        from_attributes = True 

class CourseUpdate(BaseModel):
    number_of_sessions: Optional[str] = None
    course_name: Optional[str] = None
    description: Optional[str] = None
    semesterID: Optional[int] = None
    instructorID: Optional[int] = None