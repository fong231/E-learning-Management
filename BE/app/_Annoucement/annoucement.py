from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
from .._Learning_Content import model as ContentModel

router = APIRouter(
    prefix="/announcements",
    tags=["Announcements"],
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
    db_annoucement = model.Annoucement(**annoucement.model_dump())
    
    db.add(db_annoucement)
    db.commit()
    db.refresh(db_annoucement)
    
    return {"message": "Annoucement created successfully"}

# read annoucement
@router.get("/{annoucement_id}", response_model=schema.AnnoucementRead)
def read(annoucement_id : int, db : Session = Depends(get_db)):
    annoucement = db.query(model.Annoucement).filter(model.Annoucement.annoucementID == annoucement_id).first()
    
    if not annoucement:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Annoucement not found")
    
    return annoucement

# update assignment
@router.patch("/{annoucement_id}", response_model=schema.AnnoucementRead)
def update(annoucement_id : int, assignment_data: schema.AnnoucementUpdate, db : Session = Depends(get_db)):
    db_annoucement = db.query(model.Annoucement).filter(model.Annoucement.annoucementID == annoucement_id).first()
    
    if not db_annoucement:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Annoucement not found")
    
    update_data = assignment_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_annoucement, key, value)

    db.commit()
    db.refresh(db_annoucement)
    
    return db_annoucement
    
# delete annoucement
@router.delete("/{annoucement_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(annoucement_id : int, db : Session = Depends(get_db)):
    db_annoucement = db.query(model.Annoucement).filter(model.Annoucement.annoucementID == annoucement_id).first()
    
    if not db_annoucement:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Annoucement not found")
    
    db.delete(db_annoucement)
    db.commit()

    return