from typing import Optional, Literal
from pydantic import BaseModel

class MaterialBase(BaseModel):
    title: str
    contentID: int
    description: Optional[str] = None

class MaterialCreate(MaterialBase):
    pass

class MaterialRead(MaterialBase):
    class Config:
        from_attributes = True 

class MaterialUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None