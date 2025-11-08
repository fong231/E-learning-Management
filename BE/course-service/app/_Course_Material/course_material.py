from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Course import model as CourseModel
from .._Material import model as MaterialModel
import requests
from ..config import STUDENT_BASE_URL

router = APIRouter(
    prefix="/courses",
    tags=["courses-materials"],
)

# enroll material
@router.post("/{course_id}/materials", status_code=status.HTTP_201_CREATED)
def enroll_material(course_id : int, association: schema.CourseMaterialCreate, db: Session = Depends(get_db)):
    # check course exist
    if course_id is not None:
        course = db.query(CourseModel.Course).filter(CourseModel.Course.courseID == course_id).first()
        if not course:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    #check material exist
    material_id = association.materialID
    if material_id is not None:
        material = db.query(MaterialModel.Material).filter(MaterialModel.Material.materialID == material_id).first()
        if not material:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Material not found")
    
    # check if this asociation already existed
    existing_association = db.query(model.CourseMaterialAssociation).filter(
        model.CourseMaterialAssociation.courseID == course_id,
        model.CourseMaterialAssociation.materialID == material_id
    ).first()
    
    if existing_association:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Student already enrolled in this group.")
    
    db_association = model.CourseMaterialAssociation(
        courseID = course_id,
        materialID = material_id
    )
    
    db.add(db_association)
    db.refresh(db_association)
    return {"message": f"Material {material_id} enrolled in Course {course_id} successfully."}
    
# Remove material
@router.delete("/{course_id}/materials/{material_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_material(course_id : int, material_id : int, db : Session = Depends(get_db)):
    association = db.query(model.CourseMaterialAssociation).filter(
        model.CourseMaterialAssociation.courseID == course_id,
        model.CourseMaterialAssociation.materialID == material_id
    ).first()
    
    if not association:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Material not found in this Course.")
        
    db.delete(association)
    
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