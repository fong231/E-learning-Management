from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Group import model as GroupModel
from .._Learning_Content import model as ContentModel

router = APIRouter(
    prefix="/assignments",
    tags=["Assignments"],
)

# create assignment
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(assignment: schema.AssignmentCreate, db: Session = Depends(get_db)):
    """
    require group id and content id
    """
    
    group_id = assignment.groupID
    content_id = assignment.contentID
    
    content = db.query(ContentModel.LearningContent).filter(
        ContentModel.LearningContent.contentID == content_id
    ).first()
    
    if not content:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    
    group = db.query(GroupModel.Group).filter(
        GroupModel.Group.groupID == group_id
    ).first()
    
    if not group:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
    
    # create orm model instance
    db_assignment = model.Assignment(**assignment.model_dump())
    
    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)
    
    return {"message": "Assignment created successfully"}

# read assignment
@router.get("/{assignment_id}", response_model=schema.AssignmentRead)
def read(assignment_id : int, db : Session = Depends(get_db)):
    assignment = db.query(model.Assignment).filter(model.Assignment.assignmentID == assignment_id).first()
    
    if not assignment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignment not found")
    
    return assignment

# read all assignments
@router.get("/", response_model=List[schema.AssignmentRead])
def read_all(db : Session = Depends(get_db)):
    assignments = db.query(model.Assignment).all()
    
    if not assignments:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail="No assignment found")
    
    return assignments

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
    
# delete assignment
@router.delete("/{assignment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(assignment_id : int, db : Session = Depends(get_db)):
    db_assignment = db.query(model.Assignment).filter(model.Assignment.assignmentID == assignment_id).first()
    
    if not db_assignment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignment not found")
    
    db.delete(db_assignment)
    db.commit()

    return