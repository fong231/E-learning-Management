from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from .database import get_db 
from . import schema, model
from .config import CONTENT_BASE_URL, GROUP_BASE_URL

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
    
    is_valid_respone("group", group_url)
    is_valid_respone("content", content_url)
    
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
    db.commit()
    db.refresh(db_assignment)
    return {"message": "Course created successfully"}

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