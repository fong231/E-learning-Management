from typing import List
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
from .._Learning_Content import model as ContentModel
from .._Customer import model as CustomerModel

router = APIRouter(
    prefix="/announcements",
    tags=["Announcements"],
)

comment_router = APIRouter(
    prefix="/comments",
    tags=["Comments"],
)


def _serialize_comment(db: Session, comment: model.Comment) -> schema.CommentRead:
    customer = None
    if comment.ownerID is not None:
        customer = (
            db.query(CustomerModel.Customer)
            .filter(CustomerModel.Customer.customerID == comment.ownerID)
            .first()
        )

    user_name = customer.fullname if customer else None
    user_role = customer.role if customer else "student"

    return schema.CommentRead(
        comment_id=comment.commentID,
        announcement_id=comment.announcementID,
        user_id=comment.ownerID,
        user_name=user_name,
        user_role=user_role,
        content=comment.message,
        created_at=datetime.utcnow(),
    )


# create announcement
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(annoucement: schema.AnnoucementCreate, db: Session = Depends(get_db)):
    #TODO announcement dont have any content
    
    group_id = annoucement.groupID
    content_id = annoucement.contentID
    
    content = db.query(ContentModel.LearningContent).filter(
        ContentModel.LearningContent.contentID == content_id
    ).first()
    
    if not content:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    
    group = db.query(GroupModel.Group).filter(
        GroupModel.Group.groupID == group_id
    ).first()
    
    if not group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
       
    # create orm model instance
    db_annoucement = model.Announcement(**annoucement.model_dump())
    
    db.add(db_annoucement)
    db.commit()
    db.refresh(db_annoucement)
    
    return {"message": "Annoucement created successfully"}


# read annoucement
@router.get("/{annoucement_id}", response_model=schema.AnnoucementRead)
def read(annoucement_id : int, db : Session = Depends(get_db)):
    annoucement = db.query(model.Announcement).filter(model.Announcement.announcementID == annoucement_id).first()
    
    if not annoucement:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Annoucement not found")
    
    return annoucement


# read all annoucements
@router.get("/", response_model=List[schema.AnnoucementRead])
def read_all(db : Session = Depends(get_db)):
    annoucements = db.query(model.Announcement).all()
    
    if not annoucements:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail="No announcement found")
    
    return annoucements


# update assignment
@router.patch("/{annoucement_id}", response_model=schema.AnnoucementRead)
def update(annoucement_id : int, assignment_data: schema.AnnoucementUpdate, db : Session = Depends(get_db)):
    db_annoucement = db.query(model.Announcement).filter(model.Announcement.announcementID == annoucement_id).first()
    
    if not db_annoucement:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Annoucement not found")
    
    update_data = assignment_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_annoucement, key, value)

    db.commit()
    db.refresh(db_annoucement)
    
    return db_annoucement

@router.put("/{annoucement_id}")
def put_update(annoucement_id: int, announcement_data: schema.AnnoucementUpdate, db: Session = Depends(get_db)):
    updated = update(annoucement_id, announcement_data, db)
    return {"announcement": updated}


# delete annoucement
@router.delete("/{annoucement_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(annoucement_id : int, db : Session = Depends(get_db)):
    db_annoucement = db.query(model.Announcement).filter(model.Announcement.announcementID == annoucement_id).first()
    
    if not db_annoucement:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Annoucement not found")
    
    db.delete(db_annoucement)
    db.commit()

    return