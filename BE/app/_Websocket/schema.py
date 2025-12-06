from datetime import datetime, timezone
from typing import Optional
import httpx
from pydantic import BaseModel, EmailStr, Field
from fastapi import HTTPException, status
# from ..Model import channel_model
import uuid

class ChannelMemberCreate(BaseModel):
    user_id : str
    channel_id : str