from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal

class AnnoucementBase(BaseModel):
    groupID: Optional[int] = None
    contentID: Optional[int] = None
    
class AnnoucementCreate(AnnoucementBase):
    pass
    
class AnnoucementUpdate(BaseModel):
    groupID: Optional[int] = None
    contentID: Optional[int] = None

class AnnoucementRead(AnnoucementBase):
    
    class Config:
        from_attributes = True