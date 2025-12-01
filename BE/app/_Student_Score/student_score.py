from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
from .._Student import model as StudentModel

router = APIRouter(
    prefix="/scores",
    tags=["students-scores"],
)

# create students score
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(student_scores: schema.StudentScoreCreate, db: Session = Depends(get_db)):

    student_id = student_scores.studentID
    group_id = student_scores.groupID
    
    student = db.query(StudentModel.Student).filter(
        StudentModel.Student.studentID == student_id
    ).first()
    
    if not student:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found")
    
    group = db.query(GroupModel.Group).filter(
        GroupModel.Group.groupID == group_id
    ).first()
    
    if not group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    # create orm model instance
    db_student_score = model.StudentScore(**student_scores.model_dump())
    
    db.add(db_student_score)
    db.commit()
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

    db.commit()
    db.refresh(db_student_score)
    
    return db_student_score
    
# delete assignment
@router.delete("/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(group_id : int, student_id : int, quiz_id, db : Session = Depends(get_db)):
    
    db_student_score = read(group_id, student_id, quiz_id, db)
    
    db.delete(db_student_score)
    db.commit()

    return