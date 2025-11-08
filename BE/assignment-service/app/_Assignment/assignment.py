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
@router.post("/", status_code=201)
def create(assignment: schema.AssignmentCreate, db: Session = Depends(get_db)):
    """
    require group id and content id
    """
    
    group_id = assignment.groupID
    content_id = assignment.contentID
    group_url = f"{GROUP_BASE_URL}/{group_id}"
    content_url = f"{CONTENT_BASE_URL}/{content_id}"
    
    is_valid_response("group", group_url)
    is_valid_response("content", content_url)
    
    db_assignment = model.Assignment(
        groupID = group_id,
        contentID = content_id,
        
        start_date = assignment.start_date,
        deadline = assignment.deadline,
        late_deadline = assignment.late_deadline,
        size_limit = assignment.size_limit,
        file_format = assignment.file_format
    )
    
    db.add(db_assignment)
    db.refresh(db_assignment)
    return {"message": "Assignment created successfully"}

# read assignment
@router.get("/{assignment_id}", response_model=schema.AssignmentRead)
def read(assignment_id : int, db : Session = Depends(get_db)):
    assignment = db.query(model.Assignment).filter(model.Assignment.assignmentID == assignment_id).first()
    
    if not assignment:
        raise HTTPException(status_code=404, detail="Assignment not found")
    
    return assignment

# update assignment
@router.patch("/{assignment_id}", response_model=schema.AssignmentUpdate)
def update(assignment_id : int, assignment_data: schema.AssignmentUpdate, db : Session = Depends(get_db)):
    db_assignment = db.query(model.Assignment).filter(model.Assignment.assignmentID == assignment_id).first()
    
    if not db_assignment:
        raise HTTPException(status_code=404, detail="Assignment not found")
    
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
        response = requests.get(url, timeout=5) # Add timeout for safety
        response.raise_for_status() # Raises HTTPException for 4xx/5xx status codes
        return True
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 404:
            # Raise a custom exception or just return False to handle in the endpoint
            return False 
        # Re-raise other HTTP errors (e.g., 401, 500)
        raise
    except requests.RequestException as e:
        # Catch connection errors, timeouts, etc.
        # Raise a specific error that the endpoint can catch and map to 503
        raise RuntimeError(f"External service '{name}' is unavailable: {str(e)}")