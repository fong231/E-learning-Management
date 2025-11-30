from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model

router = APIRouter(
    prefix="/students",
    tags=["Students"],
)

def create_student(db: Session, student_data: schema.StudentCreate):
    student_id = student_data.studentID

    # 1. Check if the Customer exists
    customer = db.query(model.Customer).filter(model.Customer.customerID == student_id).first()
    if not customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Customer with ID {student_id} must exist before registering as a student."
        )

    # 2. Check if the Student already exists
    existing_student = db.query(model.Student).filter(model.Student.studentID == student_id).first()
    if existing_student:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Student with ID {student_id} already registered."
        )

    # 3. Create and add the Student
    db_student = model.Student(studentID=student_id)
    db.add(db_student)
    db.commit()
    db.refresh(db_student)
    return db_student

@router.post(
    "/",
    response_model=schema.Student,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new student"
)
async def register_student(student_data: schema.StudentCreate, db: Session = Depends(get_db)):
    return create_student(db, student_data)


@router.get(
    "/{student_id}",
    response_model=schema.Student,
    summary="Get student details by ID"
)
async def read_student(student_id: int, db: Session = Depends(get_db)):
    db_student = db.query(model.Student).filter(model.Student.studentID == student_id).first()
    if db_student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found"
        )
    return db_student


@router.get(
    "/students/",
    response_model=List[schema.Student],
    summary="Get a list of all students"
)
async def read_students(db: Session = Depends(get_db), skip: int = 0, limit: int = 100):
    students = db.query(model.Student).offset(skip).limit(limit).all()
    return students


@router.delete(
    "/students/{student_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a student entry"
)
async def delete_student(student_id: int, db: Session = Depends(get_db)):
    db_student = db.query(model.Student).filter(model.Student.studentID == student_id).first()
    if db_student is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found"
        )

    db.delete(db_student)
    db.commit()
    return None