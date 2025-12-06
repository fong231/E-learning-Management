import redis.asyncio as redis
import asyncio
import json
from .connection_manager import manager
from ...config import REDIS_HOST, REDIS_PORT, REDIS_PASSWORD

redis_client: redis.Redis = None

async def init_redis():
    global redis_client
    redis_client = redis.Redis(
        host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD, decode_responses=False
    )
    await redis_client.ping()
    print("Redis connected")

async def redis_listener_task():
    from .channel_utils import get_subscribers_for_channel
    
    await init_redis()
    pubsub = redis_client.pubsub()
    await pubsub.psubscribe(b'channel:*')
    print("Redis listener started")

    while True:
        try:
            msg = await pubsub.get_message(ignore_subscribe_messages=True, timeout=1)
            if msg and msg.get('data') and isinstance(msg['data'], bytes):
                channel_bytes = msg['channel']
                data_bytes = msg['data']

                try:
                    data = json.loads(data_bytes.decode('utf-8'))
                    channel_name = channel_bytes.decode('utf-8')
                    channel_id = channel_name.split(':', 1)[-1]

                    subscribers = await get_subscribers_for_channel(channel_id)
                    print(f"Channel ID: {channel_id}. Total Subscribers: {len(subscribers)}. Subscribers list: {subscribers}")
                    if not subscribers:
                        continue

                    local_subscribers = [uid for uid in subscribers if uid in manager.active_connections]

                    if local_subscribers:
                        send_tasks = [manager._send_to_local_user(uid, data) for uid in local_subscribers]
                        await asyncio.gather(*send_tasks)
                except Exception as e:
                    print(f"Error processing Redis message: {e}")

            await asyncio.sleep(0.01)

        except asyncio.CancelledError:
            print("Redis listener cancelled")
            break
        except Exception as e:
            print(f"Listener error: {e}")
            await asyncio.sleep(5)
            pubsub = redis_client.pubsub()
            await pubsub.psubscribe(b'channel:*')
