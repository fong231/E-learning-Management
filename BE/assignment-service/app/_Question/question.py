from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Quiz import model as QuizModel
from ..config import CONTENT_BASE_URL, GROUP_BASE_URL

router = APIRouter(
    prefix="/questions",
    tags=["Questions"],
)

# create question
@router.post("/", status_code=201)
def create(question: schema.QuestionCreate, db: Session = Depends(get_db)):
    if question.quizID:
        db_quiz = db.query(QuizModel.Quiz).filter(QuizModel.Quiz.quizID == question.quizID).first()
        if not db_quiz:
            raise HTTPException(status_code=404, detail="Quiz not found")
        
    db_question = model.Question(
        level=question.level,
        answer=question.answer,
        quizID=question.quizID
    )
    
    db.add(db_question)
    db.commit()
    db.refresh(db_question)
    return {"message": "Question created successfully"}

# read question
@router.get("/{question_id}", response_model=schema.QuestionRead)
def read(question_id : int, db : Session = Depends(get_db)):
    question = db.query(model.Question).filter(model.Question.questionID == question_id).first()
    
    if not question:
        raise HTTPException(status_code=404, detail="Assignment not found")
    
    return question

# update question
@router.patch("/{assignment_id}", response_model=schema.QuestionUpdate)
def update(assignment_id : int, assignment_data: schema.QuestionUpdate, db : Session = Depends(get_db)):
    db_assignment = db.query(model.Question).filter(model.Question.assignmentID == assignment_id).first()
    
    if not db_assignment:
        raise HTTPException(status_code=404, detail="Assignment not found")
    
    update_data = assignment_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_assignment, key, value)
        
    db.commit()
    db.refresh(db_assignment)
    
    return db_assignment
    
# delete question
@router.delete("/{assignment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(assignment_id : int, db : Session = Depends(get_db)):
    db_assignment = db.query(model.Question).filter(model.Question.assignmentID == assignment_id).first()
    
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
                detail=f"{name} not found"
            )
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Service is currently unavailable: {str(e)}"
        )
        
    return True