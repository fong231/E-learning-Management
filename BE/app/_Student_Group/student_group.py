from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
import requests
from .._Student import model as StudentModel

router = APIRouter(
    prefix="/groups",
    tags=["groups-students"],
)

# enroll student
@router.post("/{group_id}/students", status_code=status.HTTP_201_CREATED)
def enroll_student(group_id : int, association: schema.StudentGroupAssociationCreate, db: Session = Depends(get_db)):
    
    # check group exist
    group = db.query(GroupModel.Group).filter(GroupModel.Group.groupID == group_id).first()
    if not group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    student_id = association.studentID

    student = db.query(StudentModel.Student).filter(
        StudentModel.Student.studentID == student_id
    ).first()
    
    if not student:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found")
    
    course_id = group.courseID
    
    course_group_ids = db.query(GroupModel.Group.groupID).filter(
        GroupModel.Group.courseID == course_id
    ).all()
    
    # Convert the list of tuples [(1,), (2,), ...] into a flat list [1, 2, ...]
    course_group_ids = [g[0] for g in course_group_ids]
    
    existing_course_enrollment = db.query(model.StudentGroupAssociation).filter(
        model.StudentGroupAssociation.studentID == student_id,
        # Check if the groupID is in the list of groups for the course
        model.StudentGroupAssociation.groupID.in_(course_group_ids)
    ).first()
    
    if existing_course_enrollment:
        if existing_course_enrollment.groupID == group_id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT, 
                detail=f"Student {student_id} is already enrolled in this group."
            )
        else:
            # This enforces the business rule: they are in a DIFFERENT group in the SAME course
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Student {student_id} is already enrolled in another group (ID: {existing_course_enrollment.groupID}) for Course {course_id}. A student can only belong to one group per course."
            )
    
    db_association = model.StudentGroupAssociation(
        groupID = group_id,
        studentID = student_id
    )
    
    db.add(db_association)
    db.commit()
    db.refresh(db_association)
    return {"message": f"Student {student_id} enrolled in Group {group_id} successfully."}

@router.get("/{group_id}/students")
def get_students_in_group(
    group_id : int,
    offset : int = Query(0, ge=0),
    limit : int = Query(20, ge=1, le=100),
    db : Session = Depends(get_db)):
    
    #TODO query to the account service to get student
    group = db.query(model.StudentGroupAssociation).filter(model.StudentGroupAssociation.groupID == group_id).first()
    if not group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    base_query = db.query(model.StudentGroupAssociation.studentID).filter(
        model.StudentGroupAssociation.groupID == group_id
    )
    
    students = base_query.offset(offset).limit(limit).all()
    
    return [student_id[0] for student_id in students]

# get student in group
@router.get("/{group_id}/students/{student_id}")
def get_student_in_group(group_id : int, student_id : int, db : Session = Depends(get_db)):
    association = db.query(model.StudentGroupAssociation).filter(
        model.StudentGroupAssociation.groupID == group_id,
        model.StudentGroupAssociation.studentID == student_id
    ).first()
    
    if not association:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found in this group.")
        
    return {"studentID": association.studentID, "groupID": association.groupID}
    
# Remove Student
@router.delete("/{group_id}/students/{student_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_student(group_id : int, student_id : int, db : Session = Depends(get_db)):
    association = db.query(model.StudentGroupAssociation).filter(
        model.StudentGroupAssociation.groupID == group_id,
        model.StudentGroupAssociation.studentID == student_id
    ).first()
    
    if not association:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found in this group.")
        
    db.delete(association)
    db.commit()
    
    return {"message": "Student unenrolled successfully"}

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