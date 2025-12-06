from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_, and_, select
from sqlalchemy.orm import Session

from ..database import get_db
from . import model as MessageModel, schema as MessageSchema
from .._Customer import model as CustomerModel


router = APIRouter(
    prefix="/messages",
    tags=["Messages"],
)

user_router = APIRouter(
    prefix="/users",
    tags=["Messages"],
)


def _serialize_message(db: Session, msg: MessageModel.Message, viewer_id: int | None = None) -> MessageSchema.MessageRead:
    sender = (
        db.query(CustomerModel.Customer)
        .filter(CustomerModel.Customer.customerID == msg.senderID)
        .first()
    )
    receiver = (
        db.query(CustomerModel.Customer)
        .filter(CustomerModel.Customer.customerID == msg.receiverID)
        .first()
    )

    sender_name = sender.fullname if sender else None
    sender_role = sender.role if sender else "student"
    receiver_name = receiver.fullname if receiver else None
    receiver_role = receiver.role if receiver else "instructor"

    is_read = False
    if viewer_id is not None and msg.receiverID == viewer_id:
        existing = (
            db.query(MessageModel.MessageRead)
            .filter(
                MessageModel.MessageRead.messageID == msg.messageID,
                MessageModel.MessageRead.userID == viewer_id,
            )
            .first()
        )
        is_read = existing is not None

    sent_at = msg.created_at if getattr(msg, "created_at", None) else datetime.utcnow()

    return MessageSchema.MessageRead(
        message_id=msg.messageID,
        sender_id=msg.senderID,
        sender_name=sender_name,
        sender_role=sender_role,
        receiver_id=msg.receiverID,
        receiver_name=receiver_name,
        receiver_role=receiver_role,
        content=msg.content,
        is_read=is_read,
        sent_at=sent_at,
    )


@router.post("/", response_model=MessageSchema.MessageRead, status_code=status.HTTP_201_CREATED)
def create_message(payload: MessageSchema.MessageCreate, db: Session = Depends(get_db)) -> MessageSchema.MessageRead:
    msg = MessageModel.Message(
        content=payload.content,
        senderID=payload.sender_id,
        receiverID=payload.receiver_id,
        created_at=datetime.utcnow(),
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return _serialize_message(db, msg, viewer_id=payload.receiver_id)


@router.get(
    "/conversation/{user1_id}/{user2_id}",
    response_model=List[MessageSchema.MessageRead],
)
def get_conversation(user1_id: int, user2_id: int, db: Session = Depends(get_db)) -> List[MessageSchema.MessageRead]:
    msgs = (
        db.query(MessageModel.Message)
        .filter(
            or_(
                and_(
                    MessageModel.Message.senderID == user1_id,
                    MessageModel.Message.receiverID == user2_id,
                ),
                and_(
                    MessageModel.Message.senderID == user2_id,
                    MessageModel.Message.receiverID == user1_id,
                ),
            )
        )
        .order_by(MessageModel.Message.created_at.asc())
        .all()
    )

    return [_serialize_message(db, m, viewer_id=user1_id) for m in msgs]


@router.delete("/{message_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_message(message_id: int, db: Session = Depends(get_db)) -> None:
    msg = (
        db.query(MessageModel.Message)
        .filter(MessageModel.Message.messageID == message_id)
        .first()
    )
    if not msg:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Message not found")

    db.delete(msg)
    db.commit()


@router.put("/{message_id}/read", status_code=status.HTTP_204_NO_CONTENT)
def mark_message_read(message_id: int, db: Session = Depends(get_db)) -> None:
    msg = (
        db.query(MessageModel.Message)
        .filter(MessageModel.Message.messageID == message_id)
        .first()
    )
    if not msg:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Message not found")

    receiver_id = msg.receiverID
    existing = (
        db.query(MessageModel.MessageRead)
        .filter(
            MessageModel.MessageRead.messageID == message_id,
            MessageModel.MessageRead.userID == receiver_id,
        )
        .first()
    )
    if not existing:
        db.add(
            MessageModel.MessageRead(
                messageID=message_id,
                userID=receiver_id,
            )
        )
        db.commit()


@user_router.get("/{user_id}/messages")
def get_user_messages(user_id: int, db: Session = Depends(get_db)):
    msgs = (
        db.query(MessageModel.Message)
        .filter(
            or_(
                MessageModel.Message.senderID == user_id,
                MessageModel.Message.receiverID == user_id,
            )
        )
        .order_by(MessageModel.Message.created_at.asc())
        .all()
    )

    data = [_serialize_message(db, m, viewer_id=user_id) for m in msgs]
    return {"messages": data}


@user_router.get("/{user_id}/messages/unread-count")
def get_unread_message_count(user_id: int, db: Session = Depends(get_db)):
    subq = (
        db.query(MessageModel.MessageRead.messageID)
        .filter(MessageModel.MessageRead.userID == user_id)
        .subquery()
    )

    unread = (
        db.query(MessageModel.Message)
        .filter(
            MessageModel.Message.receiverID == user_id,
            ~MessageModel.Message.messageID.in_(select(subq.c.messageID)),
        )
        .count()
    )

    return {"count": unread}
