from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model as GroupModel
from .._Course import model as CourseModel
from ..config import ACCOUNT_SERVICE_BASE_URL

router = APIRouter(
    prefix="/groups",
    tags=["Groups"],
)

#TODO change endpoint and create account service
# ACCOUNT_SERVICE_BASE_URL = "http://localhost:8001/accounts/instructors"

# create group
@router.post("/", status_code=201)
def create_group(group: schema.GroupCreate, db: Session = Depends(get_db)):
    course_id = group.courseID
    if course_id is not None:
        course = db.query(CourseModel.Course).filter(CourseModel.Course.courseID == course_id).first()
        
        if not course:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Course with ID '{course_id}' not found."
            )
    
    db_group = GroupModel.Group(
        courseID = course_id
    )
    
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return {"message": "Group created successfully"}

# read group
@router.get("/{group_id}", response_model=schema.GroupRead)
def read_course(group_id : int, db : Session = Depends(get_db)):
    group = db.query(GroupModel.Group).filter(GroupModel.Group.groupID == group_id).first()
    
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")
    
    return group

# update group
@router.patch("/{group_id}", response_model=schema.GroupRead)
def update_course(group_id : int, group_data: schema.GroupUpdate, db : Session = Depends(get_db)):
    db_group = db.query(GroupModel.Group).filter(GroupModel.Group.groupID == group_id).first()
    
    if not db_group:
        raise HTTPException(status_code=404, detail="Group not found")
    
    update_data = group_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_group, key, value)
        
    db.commit()
    db.refresh(db_group)
    
    return db_group
    
# delete group
@router.delete("/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_course(group_id : int, db : Session = Depends(get_db)):
    db_group = db.query(GroupModel.Group).filter(GroupModel.Group.groupID == group_id).first()
    
    if not db_group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    db.delete(db_group)
    db.commit()
    
    return