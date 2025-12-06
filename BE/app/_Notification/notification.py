from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from . import model as NotificationModel, schema as NotificationSchema


student_router = APIRouter(
    prefix="/students",
    tags=["Notifications"],
)

notification_router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"],
)


def _serialize_notification(n: NotificationModel.Notification) -> NotificationSchema.NotificationRead:
    title = "Notification"
    if n.content:
        parts = n.content.split(":", 1)
        if len(parts) == 2 and parts[0].strip():
            title = parts[0].strip()

    is_read = n.status == "read"
    created_at = n.created_at if getattr(n, "created_at", None) else datetime.utcnow()

    return NotificationSchema.NotificationRead(
        notification_id=n.notificationID,
        student_id=n.studentID,
        type=n.type,
        title=title,
        content=n.content,
        is_read=is_read,
        created_at=created_at,
    )


@student_router.get("/{student_id}/notifications")
def get_student_notifications(student_id: int, db: Session = Depends(get_db)):
    notifications = (
        db.query(NotificationModel.Notification)
        .filter(NotificationModel.Notification.studentID == student_id)
        .order_by(NotificationModel.Notification.created_at.desc())
        .all()
    )

    return {"notifications": [_serialize_notification(n) for n in notifications]}


@student_router.get("/{student_id}/notifications/unread-count")
def get_student_unread_notification_count(student_id: int, db: Session = Depends(get_db)):
    unread = (
        db.query(NotificationModel.Notification)
        .filter(
            NotificationModel.Notification.studentID == student_id,
            NotificationModel.Notification.status == "unread",
        )
        .count()
    )

    return {"count": unread}


@notification_router.put("/{notification_id}/read", status_code=status.HTTP_204_NO_CONTENT)
def mark_notification_read(notification_id: int, db: Session = Depends(get_db)):
    notif = (
        db.query(NotificationModel.Notification)
        .filter(NotificationModel.Notification.notificationID == notification_id)
        .first()
    )
    if not notif:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")

    notif.status = "read"
    db.commit()


@notification_router.delete("/{notification_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_notification(notification_id: int, db: Session = Depends(get_db)):
    notif = (
        db.query(NotificationModel.Notification)
        .filter(NotificationModel.Notification.notificationID == notification_id)
        .first()
    )
    if not notif:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")

    db.delete(notif)
    db.commit()
