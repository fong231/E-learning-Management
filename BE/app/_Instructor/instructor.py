from fastapi import APIRouter, FastAPI, HTTPException, status, Depends
from typing import List, Optional

from sqlalchemy import distinct, func, literal_column
from .schema import InstructorCreate
from sqlalchemy.orm import Session
from . import model, schema
from .._Customer import model as CustomerModel
from .._Course.model import Course
from .._Course.schema import CourseRead
from .._Student.model import Student
from .._Group.model import Group
from .._Assignment.model import Assignment
from .._Quiz.model import Quiz
from .._Student_Group.model import StudentGroupAssociation
from .._Student_Score.model import StudentScore
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

# summary
@router.get("/{instructor_id}/summary")
def get_instructor_summary(instructor_id: int, db: Session = Depends(get_db)):
    if not db.get(model.Instructor, instructor_id):
        raise HTTPException(status_code=404, detail=f"Instructor with ID {instructor_id} not found")

    total_courses = db.query(
        func.count(distinct(Course.courseID))
    ).filter(Course.instructorID == instructor_id).scalar() or 0

    group_metrics_query = db.query(
        # 3. Total Groups
        func.count(distinct(Group.groupID)).label('total_groups'),
        
        # 4. Total Assignments
        func.count(distinct(Assignment.assignmentID)).label('total_assignments'),
        
        # 2. Total Students
        func.count(distinct(StudentGroupAssociation.studentID)).label('total_students'),
    ).select_from(Course) \
     .join(Group, Course.courseID == Group.courseID) \
     .outerjoin(Assignment, Group.groupID == Assignment.groupID) \
     .outerjoin(StudentGroupAssociation, Group.groupID == StudentGroupAssociation.groupID) \
     .filter(Course.instructorID == instructor_id)
     
    group_metrics = group_metrics_query.first()

    total_quizzes = db.query(func.count(distinct(Quiz.quizID))) \
        .select_from(Course) \
        .join(Group, Course.courseID == Group.courseID) \
        .join(StudentScore, Group.groupID == StudentScore.groupID) \
        .join(Quiz, StudentScore.quizID == Quiz.quizID) \
        .filter(Course.instructorID == instructor_id) \
        .scalar() or 0

    return {
        "id": instructor_id,
        "totalCourses": total_courses,
        "totalStudents": group_metrics.total_students if group_metrics else 0,
        "totalGroups": group_metrics.total_groups if group_metrics else 0,
        "totalAssignments": group_metrics.total_assignments if group_metrics else 0,
        "totalQuizzes": total_quizzes
    }
    
@router.get("/{instructor_id}/courses", response_model=List[CourseRead])
def get_instructor_courses(
    instructor_id: int, 
    semester_id: Optional[int] = None, 
    db: Session = Depends(get_db)
):
    if not db.get(model.Instructor, instructor_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Instructor with ID {instructor_id} not found"
        )

    query = db.query(Course).filter(
        Course.instructorID == instructor_id
    )

    if semester_id is not None:
        query = query.filter(
            Course.semesterID == semester_id
        )

    courses = query.all()

    if not courses:
        return []
        
    return courses