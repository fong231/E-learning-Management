from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from ..config import STUDENT_GROUP_BASE_URL, STUDENT_BASE_URL, GROUP_BASE_URL

router = APIRouter(
    prefix="/scores",
    tags=["students-scores"],
)

# create students score
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(student_scores: schema.StudentScoreCreate, db: Session = Depends(get_db)):

    student_id = student_scores.studentID
    group_id = student_scores.groupID
    
    group_url = f"{GROUP_BASE_URL}/{group_id}"
    student_url = f"{STUDENT_BASE_URL}/{student_id}"
    student_group_url = f"{STUDENT_GROUP_BASE_URL}/{group_id}/students/{student_id}"
    
    try:
        if not check_service_availability("group", group_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
        if not check_service_availability("student", student_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found")
        if not check_service_availability("student-group", student_group_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, 
                                detail="Student in this group not found")
    except RuntimeError as e:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(e))
    
    # create orm model instance
    db_student_score = model.StudentScore(**student_scores.model_dump())
    
    db.add(db_student_score)
    db.refresh(db_student_score)
    
    return {"message": "Student's Score created successfully"}

# read student score
@router.get("/{group_id}", response_model=schema.StudentScoreRead)
def read(group_id : int, student_id : int, quiz_id: int, db : Session = Depends(get_db)):
    
    group = db.query(model.StudentScore).filter(model.StudentScore.groupID == group_id).first()
    
    if not group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    student_score = db.query(model.StudentScore).filter(
        model.StudentScore.groupID == group_id,
        model.StudentScore.quizID == quiz_id,
        model.StudentScore.studentID == student_id).first()

    if not student_score:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student's Score not found")
    
    return student_score

# update assignment
@router.patch("/{group_id}", response_model=schema.StudentScoreRead)
def update(group_id : int, student_id : int, quiz_id, assignment_data: schema.StudentScoreUpdate, db : Session = Depends(get_db)):
  
    db_student_score = read(group_id, student_id, quiz_id, db)  # Ensure the student's score exists

    update_data = assignment_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_student_score, key, value)

    db.refresh(db_student_score)
    
    return db_student_score
    
# delete assignment
@router.delete("/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(group_id : int, student_id : int, quiz_id, db : Session = Depends(get_db)):
    
    db_student_score = read(group_id, student_id, quiz_id, db)
    
    db.delete(db_student_score)

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