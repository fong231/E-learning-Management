from typing import Optional
from pydantic import BaseModel

class CourseMaterialBase(BaseModel):
    materialID: int

class CourseMaterialCreate(CourseMaterialBase):
    pass

class CourseMaterialRead(CourseMaterialBase):
    class Config:
        from_attributes = True