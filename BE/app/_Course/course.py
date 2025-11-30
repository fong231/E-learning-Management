from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Semester import model as SemesterModel
from .._Instructor import model as InstructorModel
# from .._Instructor import 

router = APIRouter(
    prefix="/courses",
    tags=["Courses"],
)

# create course
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(course: schema.CourseCreate, db: Session = Depends(get_db)):
    instructor_id = course.instructorID
    
    instructor = db.query(InstructorModel.Instructor).filter(
        InstructorModel.Instructor.instructorID == instructor_id
    ).first()
    
    if not instructor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Instructor not found")
        
    semester_id = course.semesterID
    if semester_id is not None:
        semester = db.query(SemesterModel.Semester).filter(SemesterModel.Semester.semesterID == semester_id).first()
        
        if not semester:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Semester with ID '{semester_id}' not found."
            )
    
    db_course = model.Course(**course.model_dump())
    
    db.add(db_course)
    db.commit()
    db.refresh(db_course)
    return {"message": "Course created successfully"}

# read course
@router.get("/{course_id}", response_model=schema.CourseRead)
def read(course_id : int, db : Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    return course

# update course
@router.patch("/{course_id}", response_model=schema.CourseRead)
def update(course_id : int, course_data: schema.CourseUpdate, db : Session = Depends(get_db)):
    db_course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not db_course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    semester_id = course_data.semesterID
    if semester_id is not None:
        semester = db.query(SemesterModel.Semester).filter(SemesterModel.Semester.semesterID == semester_id).first()
        
        if not semester:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Semester with ID '{semester_id}' not found."
            )
    
    update_data = course_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_course, key, value)

    db.commit()
    db.refresh(db_course)
    
    return db_course
    
# delete course
@router.delete("/{course_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(course_id : int, db : Session = Depends(get_db)):
    db_course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not db_course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    db.delete(db_course)
    db.commit()
    
    return
