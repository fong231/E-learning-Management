from pydantic import BaseModel, Field

class InstructorCreate(BaseModel):
    instructorID: int = Field(..., description="The ID of the instructor, which is also a customerID.")

class Instructor(BaseModel):
    instructorID: int = Field(..., description="The unique ID of the instructor.")

    class Config:
        from_attributes = True