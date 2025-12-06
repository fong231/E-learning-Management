from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
from .._Course import model as CourseModel
from .._Learning_Content import model as ContentModel
from .._Submission import model as SubmissionModel
from .._Student import model as StudentModel
from .._Customer import model as CustomerModel
from datetime import datetime
import os
import shutil
import uuid

router = APIRouter(
    prefix="/assignments",
    tags=["Assignments"],
)

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(CURRENT_DIR, "..", "..", "uploads", "assignment")

os.makedirs(UPLOAD_DIR, exist_ok=True)

def _serialize_assignment(db: Session, assignment: model.Assignment):
    """Serialize an Assignment to the shape expected by AssignmentModel in FE."""

    group = None
    if assignment.groupID is not None:
        group = (
            db.query(GroupModel.Group)
            .filter(GroupModel.Group.groupID == assignment.groupID)
            .first()
        )

    course = None
    if group is not None and group.courseID is not None:
        course = (
            db.query(CourseModel.Course)
            .filter(CourseModel.Course.courseID == group.courseID)
            .first()
        )

    course_id = course.courseID if course is not None else None
    course_name = course.course_name if course is not None else None

    return {
        "assignment_id": assignment.assignmentID,
        "course_id": course_id,
        "course_name": course_name,
        "group_id": group.id if group is not None else None,
        "title": assignment.title,
        "description": assignment.description,
        "deadline": assignment.deadline.isoformat() if assignment.deadline else None,
        "late_deadline": assignment.late_deadline.isoformat() if assignment.late_deadline else None,
        "size_limit": str(assignment.size_limit)
        if getattr(assignment, "size_limit", None) is not None
        else None,
        "file_format": assignment.file_format,
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": None,
        "files_url": [],
    }

@router.post("/files")
async def upload_assignment_file(file: UploadFile = File(...)):
    file_extension = os.path.splitext(file.filename or "")[1]
    unique_filename = f"assignment_{uuid.uuid4()}{file_extension}"
    file_path_on_disk = os.path.join(UPLOAD_DIR, unique_filename)

    try:
        with open(file_path_on_disk, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save file to disk: {e}",
        )
    finally:
        file.file.close()

    file_url = f"/uploads/assignment/{unique_filename}"

    return {
        "file_url": file_url,
    }

# create assignment
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(assignment: schema.AssignmentCreate, db: Session = Depends(get_db)):
    """Create a new assignment for a course/group and back it with Learning_Content.

    Expects payload from FE with:
    - course_id
    - group_id (group number within that course)
    - title, description, deadline, late_deadline, etc.
    """

    course_id = assignment.course_id
    group_local_id = assignment.group_id

    # Validate course
    course = (
        db.query(CourseModel.Course)
        .filter(CourseModel.Course.courseID == course_id)
        .first()
    )
    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    # Find group: first try by (courseID, local group id), then fallback by primary key
    group = (
        db.query(GroupModel.Group)
        .filter(
            GroupModel.Group.courseID == course_id,
            GroupModel.Group.id == group_local_id,
        )
        .first()
    )
    if not group:
        group = (
            db.query(GroupModel.Group)
            .filter(GroupModel.Group.groupID == group_local_id)
            .first()
        )

    if not group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found",
        )

    # Create backing Learning_Content row
    db_content = ContentModel.LearningContent(
        title=assignment.title,
        description=assignment.description,
    )
    db.add(db_content)
    db.commit()
    db.refresh(db_content)

    # Create the Assignment row linked to this content
    db_assignment = model.Assignment(
        assignmentID=db_content.contentID,
        title=assignment.title,
        description=assignment.description,
        start_date=assignment.start_date,
        deadline=assignment.deadline,
        late_deadline=assignment.late_deadline,
        size_limit=assignment.size_limit,
        file_format=assignment.file_format,
        groupID=group.groupID,
    )

    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)

    return {"assignment": _serialize_assignment(db, db_assignment)}

# read assignment
@router.get("/{assignment_id}")
def read(assignment_id: int, db: Session = Depends(get_db)):
    assignment = (
        db.query(model.Assignment)
        .filter(model.Assignment.assignmentID == assignment_id)
        .first()
    )

    if not assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )

    return {"assignment": _serialize_assignment(db, assignment)}

# read all assignments
@router.get("/", response_model=List[schema.AssignmentRead])
def read_all(db: Session = Depends(get_db)):
    assignments = db.query(model.Assignment).all()

    if not assignments:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail="No assignment found")
    
    return assignments

# read submissions of an assignment
@router.get("/{assignment_id}/submissions")
def get_assignment_submissions(
    assignment_id: int,
    student_id: Optional[int] = None,
    db: Session = Depends(get_db),
):
    assignment = db.query(model.Assignment).filter(
        model.Assignment.assignmentID == assignment_id
    ).first()

    if not assignment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignment not found")

    query = db.query(SubmissionModel.Submission).filter(
        SubmissionModel.Submission.assignmentID == assignment_id
    )

    if student_id is not None:
        query = query.filter(SubmissionModel.Submission.studentID == student_id)

    submissions = query.order_by(SubmissionModel.Submission.submitted_at.asc()).all()

    result = []
    for sub in submissions:
        student = (
            db.query(StudentModel.Student)
            .filter(StudentModel.Student.studentID == sub.studentID)
            .first()
        )

        customer = None
        if student is not None:
            customer = (
                db.query(CustomerModel.Customer)
                .filter(CustomerModel.Customer.customerID == student.studentID)
                .first()
            )

        student_name = customer.fullname if customer else None

        result.append(
            {
                "submission_id": sub.submissionID,
                "assignment_id": sub.assignmentID,
                "student_id": sub.studentID,
                "student_name": student_name,
                "submission_text": sub.submission_text,
                "file_url": sub.file_url,
                "submitted_at": (sub.submitted_at or datetime.utcnow()).isoformat(),
                "score": sub.score,
                "feedback": sub.feedback,
                "graded_at": sub.graded_at.isoformat() if sub.graded_at else None,
            }
        )

    return {"submissions": result}

# update assignment
@router.patch("/{assignment_id}", response_model=schema.AssignmentRead)
def update(assignment_id : int, assignment_data: schema.AssignmentUpdate, db : Session = Depends(get_db)):
    db_assignment = db.query(model.Assignment).filter(model.Assignment.assignmentID == assignment_id).first()
    
    if not db_assignment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignment not found")
    
    update_data = assignment_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_assignment, key, value)
    
    db.commit()
    db.refresh(db_assignment)
    
    return db_assignment

@router.put("/{assignment_id}")
def put_update(assignment_id: int, assignment_data: schema.AssignmentUpdate, db: Session = Depends(get_db)):
    # Reuse patch logic to apply updates
    _ = update(assignment_id, assignment_data, db)

    # Reload from DB and serialize in the same shape as other endpoints
    db_assignment = (
        db.query(model.Assignment)
        .filter(model.Assignment.assignmentID == assignment_id)
        .first()
    )

    if not db_assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )

    return {"assignment": _serialize_assignment(db, db_assignment)}

# delete assignment
@router.delete("/{assignment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(assignment_id : int, db : Session = Depends(get_db)):
    db_assignment = db.query(model.Assignment).filter(model.Assignment.assignmentID == assignment_id).first()
    
    if not db_assignment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignment not found")
    
    db.delete(db_assignment)
    db.commit()

    return