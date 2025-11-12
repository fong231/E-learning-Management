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
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(question: schema.QuestionCreate, db: Session = Depends(get_db)):
    if question.quizID:
        db_quiz = db.query(QuizModel.Quiz).filter(QuizModel.Quiz.quizID == question.quizID).first()
        if not db_quiz:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")

    db_question = model.Question(**question.model_dump())
    
    db.add(db_question)
    db.commit()
    
    db.refresh(db_question)
    return {"message": "Question created successfully"}

# read question
@router.get("/{question_id}", response_model=schema.QuestionRead)
def read(question_id : int, db : Session = Depends(get_db)):
    question = db.query(model.Question).filter(model.Question.questionID == question_id).first()
    
    if not question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
    
    return question

# update question
@router.patch("/{question_id}", response_model=schema.QuestionRead)
def update(question_id : int, assignment_data: schema.QuestionUpdate, db : Session = Depends(get_db)):
    db_question = db.query(model.Question).filter(model.Question.questionID == question_id).first()
    
    if not db_question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
    
    update_data = assignment_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_question, key, value)
    
    db.commit()
    db.refresh(db_question)
    
    return db_question
    
# delete question
@router.delete("/{question_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(question_id : int, db : Session = Depends(get_db)):
    db_question = db.query(model.Question).filter(model.Question.questionID == question_id).first()
    
    if not db_question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
    
    db.delete(db_question)
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
        if e.response.status_code == status.HTTP_404_NOT_FOUND:
            return False 
        raise
    except requests.RequestException as e:
        raise RuntimeError(f"External service '{name}' is unavailable: {str(e)}")