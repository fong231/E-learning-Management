import httpx
from fastapi import Depends, HTTPException, status
from typing import Optional
# from ..config import EMPLOYEE_SERVICE_BASE_URL
from . import redis_utils
# from ..Model import channel_member_model, channel_model, message_model
from .. import schema
from sqlalchemy.orm import Session
from ...database import get_db

# def get_channel(channel_id : str, db : Session):
#     channel = db.query(channel_model.Channel).filter(
#         channel_model.Channel.channel_id == channel_id
#     ).first()
    
#     return channel

# def get_channel(channel_id : str, db : Session):
    
    
# def get_user_in_channel(account_id : str, channel_id : str, db : Session):
#     user_channel = db.query(channel_member_model.ChannelMember).filter(
#         channel_member_model.ChannelMember.user_id == account_id,
#         channel_member_model.ChannelMember.channel_id == channel_id
#     ).first()

#     return user_channel

# def create_channel(channel_id : str, db : Session):
#     channel = get_channel(channel_id, db)
    
#     if channel:
#         return channel

#     channel = schema.ChannelCreate(
#         channel_id=channel_id,
#         channel_type=channel_model.ChannelTypeEnum.Group
#     )
    
#     channel_data = channel.model_dump()
#     db_channel = channel_model.Channel(**channel_data)
    
#     db.add(db_channel)
#     try:
#         db.commit()
#     except Exception as e:
#         db.rollback() 
#         raise e
    
#     return db_channel

# def create_channel_member(channel_id : str, account_id : str, db : Session):
#     channel = create_channel(channel_id, db)
    
#     member = get_user_in_channel(account_id, channel.channel_id, db)
    
#     if member:
#         return member
    
#     channel_member = schema.ChannelMemberCreate(
#         user_id=account_id,
#         channel_id=channel.channel_id
#     )
    
#     channel_member_data = channel_member.model_dump()
#     db_channel_member = channel_member_model.ChannelMember(**channel_member_data)
    
#     db.add(db_channel_member)
#     try:
#         db.commit()
#     except Exception as e:
#         db.rollback() 
#         raise e

#     return db_channel_member

# async def add_message_to_db(message: schema.MessageCreate, db: Session):
#     message_data = message.model_dump()

#     db_message = message_model.Message(**message_data)

#     db.add(db_message)

#     try:
#         db.commit()
#     except Exception:
#         db.rollback()
#         raise

#     db.refresh(db_message)
#     return db_message

# async def authorize_channel_membership(account_id: str, channel_id: str, token : str, db : Session) -> bool:
#     AUTH_ENDPOINT = f"{EMPLOYEE_SERVICE_BASE_URL}/{account_id}/organizations/{channel_id}/is-member"
    
#     headers = {
#         "Authorization": f"Bearer {token}",
#         "Content-Type": "application/json" 
#     }
    
#     # check in db first
#     if get_user_in_channel(account_id, channel_id, db):
#         return True
    
#     try:
#         async with httpx.AsyncClient() as client:
#             response = await client.get(AUTH_ENDPOINT, headers=headers)

#             if response.status_code == status.HTTP_200_OK:
#                 create_channel_member(channel_id, account_id, db)
#                 return True

#             return False
            
#     except httpx.HTTPError as e:
#         print(f"ERROR: Could not reach Project Service for authorization: {e}")
#         return False
    
async def subscribe_user_to_channel(account_id: str, channel_id: str):
    """
    Adds the user's account_id to a Redis SET representing the channel subscribers.
    """
    channel_key = f"subscribers:channel:{channel_id}"
    await redis_utils.redis_client.sadd(channel_key, account_id)
    print(f"User {account_id} successfully subscribed to {channel_id}.")
    
async def unsubscribe_user_from_channel(account_id: str, channel_id: str):
    """
    Removes the user's account_id from the Redis SET representing the channel subscribers.
    """
    channel_key = f"subscribers:channel:{channel_id}"

    removed_count = await redis_utils.redis_client.srem(channel_key, account_id)
    
    if removed_count > 0:
        print(f"User {account_id} successfully unsubscribed from {channel_id}.")
    else:
        print(f"User {account_id} was not a subscriber of {channel_id}.")

async def get_subscribers_for_channel(channel_id: str) -> set[str]:
    """Retrieves all account_ids subscribed to a channel."""
    channel_key = f"subscribers:channel:{channel_id}"

    subscribers_bytes = await redis_utils.redis_client.smembers(channel_key)

    subscribers = {s.decode('utf-8') for s in subscribers_bytes}

    return subscribers # Returns a set of strings