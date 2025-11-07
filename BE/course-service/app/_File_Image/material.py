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
@router.post("/", status_code=201)
def create(material: schema.MaterialCreate, db: Session = Depends(get_db)):
    material_id = material.materialID
    
    # check if content id exist
    if material_id is not None:
        material = db.query(Learning_ContentModel.Learning_Content).filter(
            Learning_ContentModel.Learning_Content.contentID == material_id).first()
        
        if material is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    
    # check duplicate in material
    if db.query(model.FileImage).filter(model.FileImage.materialID == material_id).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=f"Material with ID '{material_id}' already exists.")
    
    db_material = model.FileImage(
        materialID = material_id,
        title = material.title,
        description = material.description
    )
    
    db.add(db_material)
    db.commit()
    db.refresh(db_material)
    return {"message": "Material created successfully"}

# read material
@router.get("/{material_id}", response_model=schema.MaterialRead)
def read(material_id : int, db : Session = Depends(get_db)):
    material = db.query(model.FileImage).filter(model.FileImage.materialID == material_id).first()
    
    if not material:
        raise HTTPException(status_code=404, detail="Material not found")
    
    return material

# update material
@router.patch("/{material_id}", response_model=schema.MaterialRead)
def update(material_id : int, course_data: schema.MaterialUpdate, db : Session = Depends(get_db)):
    db_material = db.query(model.FileImage).filter(model.FileImage.materialID == material_id).first()
    
    if not db_material:
        raise HTTPException(status_code=404, detail="Material not found")
    
    update_data = course_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_material, key, value)
        
    db.commit()
    db.refresh(db_material)
    
    return db_material
    
# delete material
@router.delete("/{material_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(material_id : int, db : Session = Depends(get_db)):
    db_material = db.query(model.FileImage).filter(model.FileImage.materialID == material_id).first()
    
    if not db_material:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Material not found")
    
    db.delete(db_material)
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