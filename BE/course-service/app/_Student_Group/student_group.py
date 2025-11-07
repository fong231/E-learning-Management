from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import schema as GroupSchema, model as GroupModel
import requests
from ..config import STUDENT_BASE_URL

router = APIRouter(
    prefix="/groupss",
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
    try:
        respone = requests.get(f"{STUDENT_BASE_URL}/{student_id}")
        if respone.status_code == status.HTTP_404_NOT_FOUND:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, 
                detail= f"Student ID '{student_id}' not found"
            )
        elif respone.status_code != status.HTTP_200_OK:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Account Service communication failed."
            )
    except requests.exceptions.RequestException:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE, 
            detail="Account Service Unavailable"
        )
    
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
    
# Remove Student
@router.delete("/{group_id}/students/{student_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_semester(group_id : int, student_id : int, db : Session = Depends(get_db)):
    association = db.query(model.StudentGroupAssociation).filter(
        model.StudentGroupAssociation.groupID == group_id,
        model.StudentGroupAssociation.studentID == student_id
    ).first()
    
    if not association:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found in this group.")
        
    db.delete(association)
    db.commit()
    
    return