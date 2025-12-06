from datetime import datetime
import json
import bcrypt
from fastapi import APIRouter, Depends, FastAPI, HTTPException, WebSocketDisconnect, status, WebSocket
from pydantic import EmailStr
from contextlib import asynccontextmanager
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
# from _Message.model import Message, MessageRead
from .._Message import schema as MessageSchema
# from .config import ACCOUNT_SERVICE_BASE_URL
from ..dependencies.auth import get_raw_token, get_current_active_user, get_websocket_user_id
# from .Realtime.channel_utils import add_message_to_db
from.Realtime import redis_utils
from .Realtime.connection_manager import manager
from .Realtime.channel_utils import subscribe_user_to_channel, unsubscribe_user_from_channel
import asyncio
from .._Message.message import create_message

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Application Startup: Initializing Redis listener...")
    
    # 1. Initialize Redis connection
    await redis_utils.init_redis()
    
    # 2. Start the Redis Pub/Sub listener in the background
    redis_task = asyncio.create_task(redis_utils.redis_listener_task())

    # Yield control to the application (This is when the app starts serving requests)
    yield

    # --- SHUTDOWN LOGIC ---
    print("Application Shutdown: Cleaning up background tasks...")
    redis_task.cancel()
    try:
        await redis_task
    except asyncio.CancelledError:
        print("Redis listener task successfully cancelled.")

router = APIRouter(
    prefix="/ws",
    tags=["Realtimes"],
    lifespan=lifespan
)

@router.websocket("/{token}")
async def websocket_endpoint(
    websocket: WebSocket, 
    token: str,
    account_id: int = Depends(get_websocket_user_id),
    db : Session = Depends(get_db)
):
    account_id = str(account_id)
    await manager.connect(account_id, websocket) 

    try:
        while True:
            data = await websocket.receive_text()
            
            if not data.strip():
                continue

            try:
                message = json.loads(data)
            except json.JSONDecodeError:
                await manager._send_to_local_user(account_id, {"error": "Invalid JSON"})
                continue
                
            action = message.get("action")
            # channel_id: id cần kết nối vào để chat
            # 1 - 1 chat: nên là student_id + instructor_id
            # forum chat: nên là forum_id
            channel_id = message.get("receiver_id")
            
            if not action or not channel_id:
                await manager._send_to_local_user(account_id, {"error": "Missing action or channel_id"})
                continue

            if action == "subscribe":
                # is_member = await authorize_channel_membership(account_id, channel_id, token, db)
                
                # if is_member:
                await subscribe_user_to_channel(account_id, channel_id)
                await manager._send_to_local_user(account_id, 
                    {"status": "success", "detail": f"Subscribed to {channel_id}. Ready for real-time updates."})
                # else:
                #     await manager._send_to_local_user(account_id, 
                #         {"status": "error", "detail": f"Forbidden: Not a member of {channel_id}"})
                    
            elif action == "unsubscribe":
                await unsubscribe_user_from_channel(account_id, channel_id) 
                await manager._send_to_local_user(account_id, {"status": "success", "detail": f"Unsubscribed from {channel_id}."})

            # SEND MESSAGE
            elif action == "message":
                
                message_content = message.get("content")
                
                message_data = MessageSchema.MessageCreate(
                    content=message_content,
                    receiver_id=channel_id,
                    sender_id=account_id,
                )

                # await add_message_to_db(message_data, db)
                create_message(message_data, db)
                
                payload = {
                    "type": "new_message",
                    "sender_id": account_id,
                    "content": message_content,
                    "receiver_id": channel_id,
                    "created_at": datetime.now().isoformat()
                }
                
                await manager.publish_to_channel(channel_id, payload)
                
            else:
                await manager._send_to_local_user(account_id, {"error": f"Unknown action: {action}"})
            
    except WebSocketDisconnect:
        manager.disconnect(account_id, websocket)
        print(f"User {account_id} disconnected.")

# @router.get("/channels/{channel_id}/messages", response_model=list[MessageSchema.MessageRead])
# def load_old_messages(
#     channel_id: str,
#     before_id: int | None = None,     # message_id < before_id
#     limit: int = 50,                  # default: load 50 messages
#     db: Session = Depends(get_db)
# ):
#     query = db.query(Message).filter(Message.channel_id == channel_id)

#     if before_id:
#         query = query.filter(message_model.Message.message_id < before_id)

#     messages = query.order_by(message_model.Message.message_id.desc()).limit(limit).all()

#     return list(reversed(messages))

# @router.post("/message")
# async def post_message_to_channel(
#     payload: schema.MessageCreate,
#     db: Session = Depends(get_db)
# ):
#     await add_message_to_db(payload, db)

#     ws_payload = {
#         "type": "notificaiton",
#         "sender_id": payload.sender_user_id,
#         "content": payload.content,
#         "channel_id": payload.channel_id,
#         "timestamp": datetime.now().isoformat()
#     }

#     await manager.publish_to_channel(payload.channel_id, ws_payload)

#     return {"status": "ok"}