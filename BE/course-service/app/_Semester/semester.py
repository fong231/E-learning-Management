from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model


router = APIRouter(
    prefix="/semesters",
    tags=["Semesters"],
)

# create semester
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(semester: schema.SemesterCreate, db: Session = Depends(get_db)):
    db_semester = model.Semester(
        description = semester.description
    )
    
    db.add(db_semester)
    db.commit()
    db.refresh(db_semester)
    return {"message": "Semester created successfully"}

# read semester
@router.get("/{semester_id}", response_model=schema.SemesterRead)
def read(semester_id : int, db : Session = Depends(get_db)):
    semester = db.query(model.Semester).filter(model.Semester.semesterID == semester_id).first()
    
    if not semester:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Semester not found")
    
    return semester

# update semester
@router.patch("/{semester_id}", response_model=schema.SemesterRead)
def update(semester_id : int, semester_data: schema.SemesterUpdate, db : Session = Depends(get_db)):
    db_semester = db.query(model.Semester).filter(model.Semester.semesterID == semester_id).first()
    
    if not db_semester:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Semester not found")
    
    update_data = semester_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_semester, key, value)
    
    db.commit()
    db.refresh(db_semester)
    
    return db_semester
    
# delete semester
@router.delete("/{semester_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(semester_id : int, db : Session = Depends(get_db)):
    db_semester = db.query(model.Semester).filter(model.Semester.id == semester_id).first()
    
    if not db_semester:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Semester not found")
    
    db.delete(db_semester)
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