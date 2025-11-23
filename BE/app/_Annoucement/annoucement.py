from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model

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
    group_url = f"{GROUP_BASE_URL}/{group_id}"
    content_url = f"{CONTENT_BASE_URL}/{content_id}"
    
    # check group and content existence in another service
    try:
        if not check_service_availability("group", group_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
        if not check_service_availability("content", content_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    except RuntimeError as e:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(e))
    
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

# helper function
def check_service_availability(name: str, url: str) -> bool:
    """Requests the endpoint to check if the external item exists."""
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return True
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 404:
            return False 
        raise
    except requests.RequestException as e:
        raise RuntimeError(f"External service '{name}' is unavailable: {str(e)}")