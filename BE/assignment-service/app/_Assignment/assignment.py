from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from ..config import CONTENT_BASE_URL, GROUP_BASE_URL

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
    group_url = f"{GROUP_BASE_URL}/{group_id}"
    content_url = f"{CONTENT_BASE_URL}/{content_id}"
    
    # check group and content existence in another service
    try:
        if not check_service_availability("group", group_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Group not found")
        if not check_service_availability("content", content_url):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    except RuntimeError as e:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=str(e))
    
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

# helper function
def check_service_availability(name: str, url: str) -> bool:
    """Requests the endpoint to check if the external item exists."""
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return True
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 404:
            return False 
        raise
    except requests.RequestException as e:
        raise RuntimeError(f"External service '{name}' is unavailable: {str(e)}")