from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Learning_Content import model as Learning_ContentModel
from ..config import INSTRUCTOR_BASE_URL

router = APIRouter(
    prefix="/materials",
    tags=["Materials"],
)

# create material
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(material: schema.MaterialCreate, db: Session = Depends(get_db)):
    content_id = material.contentID
    
    # check if content id exist
    if content_id is not None:
        material = db.query(Learning_ContentModel.LearningContent).filter(
            Learning_ContentModel.LearningContent.contentID == content_id).first()
        
        if material is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    
    db_material = model.Material(**material.model_dump())
    
    db.add(db_material)
    db.commit()
    db.refresh(db_material)
    return {"message": "Material created successfully"}


# read material
@router.get("/{material_id}", response_model=schema.MaterialRead)
def read(material_id : int, db : Session = Depends(get_db)):
    material = db.query(model.Material).filter(model.Material.materialID == material_id).first()
    
    if not material:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Material not found")
    
    return material

# update material
@router.patch("/{material_id}", response_model=schema.MaterialRead)
def update(material_id : int, course_data: schema.MaterialUpdate, db : Session = Depends(get_db)):
    db_material = db.query(model.Material).filter(model.Material.materialID == material_id).first()
    
    if not db_material:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Material not found")
    
    update_data = course_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_material, key, value)

    db.commit()
    db.refresh(db_material)
    
    return db_material
    
# delete material
@router.delete("/{material_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(material_id : int, db : Session = Depends(get_db)):
    db_material = db.query(model.Material).filter(model.Material.materialID == material_id).first()
    
    if not db_material:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Material not found")
    
    db.delete(db_material)
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
        if e.response.status_code == status.HTTP_404_NOT_FOUND:
            return False 
        raise
    except requests.RequestException as e:
        raise RuntimeError(f"External service '{name}' is unavailable: {str(e)}")