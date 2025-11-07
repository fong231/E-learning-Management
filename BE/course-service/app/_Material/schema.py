from typing import Optional, Literal
from pydantic import BaseModel

class MaterialBase(BaseModel):
    materialID: int
    title: str
    description: Optional[str] = None

class MaterialCreate(MaterialBase):
    title: str
    materialID: int

class MaterialRead(MaterialBase):
    class Config:
        from_attributes = True 

class MaterialUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None