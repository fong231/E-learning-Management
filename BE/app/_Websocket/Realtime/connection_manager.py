import asyncio
from fastapi import WebSocket
from typing import Dict, List
import json

class ConnectionManager:
    # { account_id: [WebSocket, WebSocket, ...] }
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, account_id: str, websocket: WebSocket):
        await websocket.accept()
        if account_id not in self.active_connections:
            self.active_connections[account_id] = []
        self.active_connections[account_id].append(websocket)
        print(f"User {account_id} connected to THIS instance.")

    def disconnect(self, account_id: str, websocket: WebSocket):
        if account_id in self.active_connections:
            self.active_connections[account_id].remove(websocket)
            if not self.active_connections[account_id]:
                del self.active_connections[account_id]
        print(f"User {account_id} disconnected from THIS instance.")

    async def _send_to_local_user(self, account_id: str, message: dict):
        """Sends a message to all active connections for a single user on THIS instance."""
        connections = self.active_connections.get(account_id, [])
        if not connections:
            return # User is not connected to this instance

        print(f"Sending message locally to {account_id} ({len(connections)} connections).")

        for connection in list(connections): 
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Error sending to {account_id} locally: {e}. Disconnecting.")
                self.disconnect(account_id, connection)

    async def publish_to_channel(self, channel_id: str, message: dict):
        """Publishes a message to a Redis Pub/Sub channel for cross-instance delivery."""
        
        from .redis_utils import redis_client

        if redis_client is None:
             print("ERROR: Redis client is not initialized. Cannot publish.")
             return

        channel_name = f"channel:{channel_id}"
        message_str = json.dumps(message)

        await redis_client.publish(channel_name, message_str)
        print(f"Message published to Redis Pub/Sub channel: {channel_name}")

manager = ConnectionManager()