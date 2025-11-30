from fastapi import APIRouter, FastAPI, HTTPException, status, Depends
from typing import List
from .schema import Instructor, InstructorCreate
from sqlalchemy.orm import Session
from . import model, schema
from .._Customer import model as CustomerModel
from ..database import get_db

router = APIRouter(
    prefix="/instructors",
    tags=["Instructors"],
)

def create_instructor(db: Session, instructor_data: schema.InstructorCreate):
    instructor_id = instructor_data.instructorID

    customer = db.query(CustomerModel.Customer).filter(CustomerModel.Customer.customerID == instructor_id).first()
    if not customer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Customer must exist before registering as an instructor."
        )

    existing_instructor = db.query(model.Instructor).filter(model.Instructor.instructorID == instructor_id).first()
    if existing_instructor:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Instructor with ID {instructor_id} already registered."
        )

    db_instructor = model.Instructor(instructorID=instructor_id)
    db.add(db_instructor)
    db.commit()
    db.refresh(db_instructor)
    return db_instructor

@router.post(
    "/",
    response_model=schema.Instructor,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new instructor"
)
async def register_instructor(instructor_data: schema.InstructorCreate, db: Session = Depends(get_db)):
    return create_instructor(db, instructor_data)


@router.get(
    "/{instructor_id}",
    response_model=schema.Instructor,
    summary="Get instructor details by ID"
)
async def read_instructor(instructor_id: int, db: Session = Depends(get_db)):
    db_instructor = db.query(model.Instructor).filter(model.Instructor.instructorID == instructor_id).first()
    if db_instructor is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Instructor not found"
        )
    return db_instructor


@router.get(
    "/",
    response_model=List[schema.Instructor],
    summary="Get a list of all instructors"
)
async def read_instructors(db: Session = Depends(get_db), skip: int = 0, limit: int = 100):
    instructors = db.query(model.Instructor).offset(skip).limit(limit).all()
    return instructors


@router.delete(
    "/instructors/{instructor_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete an instructor entry"
)
async def delete_instructor(instructor_id: int, db: Session = Depends(get_db)):
    db_instructor = db.query(model.Instructor).filter(model.Instructor.instructorID == instructor_id).first()
    if db_instructor is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Instructor not found"
        )

    db.delete(db_instructor)
    db.commit()
    return None