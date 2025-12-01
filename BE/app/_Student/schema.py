from pydantic import BaseModel, Field

class StudentCreate(BaseModel):
    studentID: int = Field(..., description="The ID of the student, which must be an existing customerID.")
    
class Student(BaseModel):
    studentID: int = Field(..., description="The unique ID of the student.")

    class Config:
        from_attributes = True