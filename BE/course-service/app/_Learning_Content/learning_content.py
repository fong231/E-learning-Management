from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from ..config import INSTRUCTOR_BASE_URL

router = APIRouter(
    prefix="/contents",
    tags=["Contents"],
)

# create content
@router.post("/", status_code=201)
def create(content: schema.Learning_ContentCreate, db: Session = Depends(get_db)):
    db_content = model.Learning_Content(
        title = content.title,
        description = content.description
    )
    
    db.add(db_content)
    db.commit()
    db.refresh(db_content)
    return {"message": "Content created successfully"}

# read content
@router.get("/{content_id}", response_model=schema.Learning_ContentRead)
def read(content_id : int, db : Session = Depends(get_db)):
    content = db.query(model.Learning_Content).filter(model.Learning_Content.contentID == content_id).first()
    
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    return content

# update content
@router.patch("/{content_id}", response_model=schema.Learning_ContentRead)
def update(content_id : int, course_data: schema.Learning_ContentUpdate, db : Session = Depends(get_db)):
    db_content = db.query(model.Learning_Content).filter(model.Learning_Content.contentID == content_id).first()
    
    if not db_content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    update_data = course_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_content, key, value)
        
    db.commit()
    db.refresh(db_content)
    
    return db_content
    
# delete content
@router.delete("/{content_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(content_id : int, db : Session = Depends(get_db)):
    db_content = db.query(model.Learning_Content).filter(model.Learning_Content.contentID == content_id).first()
    
    if not db_content:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    
    db.delete(db_content)
    db.commit()
    
    return

# helper function
def is_valid_respone(name : str, url : str):
    """
    request to the given endpoint to check if the item exist
    """
    try:
        respone = requests.get(url)
        
        if respone.status_code == status.HTTP_404_NOT_FOUND:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{name} with ID '{respone}' not found"
            )
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Service is currently unavailable: {str(e)}"
        )
        
    return True