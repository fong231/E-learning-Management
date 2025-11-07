from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
import requests
from ..config import STUDENT_BASE_URL

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
    
    # check student exist
    # is_valid_respone("Student", student_id)
    
    # check if this asociation already existed
    existing_association = db.query(model.StudentGroupAssociation).filter(
        model.StudentGroupAssociation.groupID == group_id,
        model.StudentGroupAssociation.studentID == student_id
    ).first()
    
    if existing_association:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Student already enrolled in this group.")
    
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
    
    return

# helper function
def is_valid_respone(name : str, url : str):
    """
    request to the given endpoint to check if the item exist
    """
    try:
        respone = requests.get(url)
        
        if respone.status_code == status.HTTP_404_NOT_FOUND:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{name} with ID '{respone}' not found"
            )
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Service is currently unavailable: {str(e)}"
        )
        
    return True