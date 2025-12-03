from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Course import model as CourseModel

router = APIRouter(
    prefix="/groups",
    tags=["Groups"],
)

# create group
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(group: schema.GroupCreate, db: Session = Depends(get_db)):
    
    course_id = group.courseID
    if course_id is not None:
        course = db.query(CourseModel.Course).filter(CourseModel.Course.courseID == course_id).first()
        if not course:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Course with ID '{course_id}' not found."
            )
    
    db_group = model.Group(**group.model_dump())
    
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return {"message": "Group created successfully"}

# read group
@router.get("/{group_id}", response_model=schema.GroupRead)
def read(group_id : int, db : Session = Depends(get_db)):
    group = db.query(model.Group).filter(model.Group.groupID == group_id).first()
    
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")
    
    return group 

# update group
@router.patch("/{group_id}", response_model=schema.GroupRead)
def update(group_id : int, group_data: schema.GroupUpdate, db : Session = Depends(get_db)):
    db_group = db.query(model.Group).filter(model.Group.groupID == group_id).first()
    
    if not db_group:
        raise HTTPException(status_code=404, detail="Group not found")
    
    course_id = group_data.courseID
    course = db.query(CourseModel.Course).filter(CourseModel.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    
    update_data = group_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_group, key, value)

    db.commit()
    db.refresh(db_group)
    
    return db_group
    
# delete group
@router.delete("/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(group_id : int, db : Session = Depends(get_db)):
    db_group = db.query(model.Group).filter(model.Group.groupID == group_id).first()
    
    if not db_group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    db.delete(db_group)
    
    return