from datetime import datetime
from typing import List
import os
import shutil
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from ..database import get_db
from . import model as TopicModel, schema as TopicSchema
from .._Course import model as CourseModel
from .._Customer import model as CustomerModel
from .._Student import model as StudentModel


router = APIRouter(
    prefix="/topics",
    tags=["Topics"],
)

chat_router = APIRouter(
    prefix="/topic-chats",
    tags=["Topic Chats"],
)


CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(CURRENT_DIR, "..", "..", "uploads", "forum")

os.makedirs(UPLOAD_DIR, exist_ok=True)


def _serialize_topic(db: Session, topic: TopicModel.Topic) -> TopicSchema.TopicRead:
    course = (
        db.query(CourseModel.Course)
        .filter(CourseModel.Course.courseID == topic.courseID)
        .first()
    )
    course_name = course.course_name if course else None

    creator_id = course.instructorID if course else None
    creator_name = None
    creator_role = "instructor"
    if creator_id is not None:
        customer = (
            db.query(CustomerModel.Customer)
            .filter(CustomerModel.Customer.customerID == creator_id)
            .first()
        )
        if customer:
            creator_name = customer.fullname
            creator_role = customer.role

    reply_count = (
        db.query(TopicModel.TopicChat)
        .filter(TopicModel.TopicChat.topicID == topic.topicID)
        .count()
    )
    view_count = reply_count

    created_at = topic.created_at or datetime.utcnow()

    return TopicSchema.TopicRead(
        id=topic.topicID,
        course_id=topic.courseID,
        course_name=course_name,
        creator_id=creator_id,
        creator_name=creator_name,
        creator_role=creator_role,
        title=topic.title,
        content=topic.description or "",
        view_count=view_count,
        reply_count=reply_count,
        created_at=created_at,
        updated_at=None,
    )


def _serialize_chat(db: Session, chat: TopicModel.TopicChat) -> TopicSchema.TopicChatRead:
    user_id = chat.studentID or 0
    user_name = None
    user_role = "student"

    if chat.studentID is not None:
        student = (
            db.query(StudentModel.Student)
            .filter(StudentModel.Student.studentID == chat.studentID)
            .first()
        )
        if student and student.customer:
            user_name = student.customer.fullname
            user_role = student.customer.role

    created_at = datetime.utcnow()

    return TopicSchema.TopicChatRead(
        id=chat.messageID,
        topic_id=chat.topicID,
        user_id=user_id,
        user_name=user_name,
        user_role=user_role,
        message=chat.message,
        created_at=created_at,
    )


@router.get("/{topic_id}", response_model=TopicSchema.TopicRead)
def get_topic(topic_id: int, db: Session = Depends(get_db)) -> TopicSchema.TopicRead:
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")
    return _serialize_topic(db, topic)


@router.post("", response_model=TopicSchema.TopicRead, status_code=status.HTTP_201_CREATED)
def create_topic(
    payload: TopicSchema.TopicCreate, db: Session = Depends(get_db)
) -> TopicSchema.TopicRead:
    topic = TopicModel.Topic(
        title=payload.title,
        description=payload.content,
        courseID=payload.course_id,
        created_at=datetime.utcnow(),
    )
    db.add(topic)
    db.commit()
    db.refresh(topic)
    return _serialize_topic(db, topic)


@router.put("/{topic_id}", response_model=TopicSchema.TopicRead)
def update_topic(
    topic_id: int,
    payload: TopicSchema.TopicUpdate,
    db: Session = Depends(get_db),
) -> TopicSchema.TopicRead:
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")

    data = payload.model_dump(exclude_unset=True)
    if "title" in data:
        topic.title = data["title"]
    if "content" in data:
        topic.description = data["content"]

    db.commit()
    db.refresh(topic)
    return _serialize_topic(db, topic)


@router.delete("/{topic_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_topic(topic_id: int, db: Session = Depends(get_db)) -> None:
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")

    db.delete(topic)
    db.commit()


@router.get("/{topic_id}/chats", response_model=List[TopicSchema.TopicChatRead])
def get_topic_chats(
    topic_id: int, db: Session = Depends(get_db)
) -> List[TopicSchema.TopicChatRead]:
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")

    chats = (
        db.query(TopicModel.TopicChat)
        .filter(TopicModel.TopicChat.topicID == topic_id)
        .order_by(TopicModel.TopicChat.messageID.asc())
        .all()
    )
    return [_serialize_chat(db, chat) for chat in chats]


@chat_router.post("/", response_model=TopicSchema.TopicChatRead, status_code=status.HTTP_201_CREATED)
def create_topic_chat(
    payload: TopicSchema.TopicChatCreate, db: Session = Depends(get_db)
) -> TopicSchema.TopicChatRead:
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == payload.topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")

    chat = TopicModel.TopicChat(
        message=payload.message,
        topicID=payload.topic_id,
        studentID=payload.user_id,
    )
    db.add(chat)
    db.commit()
    db.refresh(chat)
    return _serialize_chat(db, chat)


@chat_router.delete("/{chat_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_topic_chat(chat_id: int, db: Session = Depends(get_db)) -> None:
    chat = (
        db.query(TopicModel.TopicChat)
        .filter(TopicModel.TopicChat.messageID == chat_id)
        .first()
    )
    if not chat:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat not found")

    db.delete(chat)
    db.commit()


@router.post("/{topic_id}/files")
async def upload_topic_file(
    topic_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")

    file_extension = os.path.splitext(file.filename or "")[1]
    unique_filename = f"topic_{topic_id}_{uuid.uuid4()}{file_extension}"
    file_path_on_disk = os.path.join(UPLOAD_DIR, unique_filename)

    try:
        with open(file_path_on_disk, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save file to disk: {e}",
        )
    finally:
        file.file.close()

    relative_path = os.path.join("forum", unique_filename).replace("\\", "/")

    db_file = TopicModel.TopicFile(
        path=relative_path,
        topicID=topic_id,
    )

    db.add(db_file)
    db.commit()
    db.refresh(db_file)

    return {
        "file_id": db_file.fileID,
        "topic_id": db_file.topicID,
        "file_url": db_file.path,
    }


@router.get("/{topic_id}/files")
def list_topic_files(topic_id: int, db: Session = Depends(get_db)):
    topic = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.topicID == topic_id)
        .first()
    )
    if not topic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Topic not found")

    files = (
        db.query(TopicModel.TopicFile)
        .filter(TopicModel.TopicFile.topicID == topic_id)
        .order_by(TopicModel.TopicFile.fileID.asc())
        .all()
    )

    return {
        "files": [
            {
                "file_id": f.fileID,
                "topic_id": f.topicID,
                "file_url": f.path,
            }
            for f in files
        ]
    }
