from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model

router = APIRouter(
    prefix="/quizzes",
    tags=["Quizzes"],
)

# create quiz
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(quiz: schema.QuizCreate, db: Session = Depends(get_db)):
    
    db_quiz = model.Quiz(**quiz.model_dump())
    
    db.add(db_quiz)
    db.commit()
    db.refresh(db_quiz)
    return {"message": "Quiz created successfully"}

# read quiz
@router.get("/{quiz_id}", response_model=schema.QuizRead)
def read(quiz_id : int, db : Session = Depends(get_db)):
    quiz = db.query(model.Quiz).filter(model.Quiz.quizID == quiz_id).first()
    
    if not quiz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")
    
    return quiz

# update quiz
@router.patch("/{quiz_id}", response_model=schema.QuizRead)
def update(quiz_id : int, quiz_data: schema.QuizUpdate, db : Session = Depends(get_db)):
    db_quiz = db.query(model.Quiz).filter(model.Quiz.quizID == quiz_id).first()
    
    if not db_quiz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")
    
    update_data = quiz_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_quiz, key, value)
    
    db.commit()
    db.refresh(db_quiz)
    
    return db_quiz
    
# delete quiz
@router.delete("/{quiz_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(quiz_id : int, db : Session = Depends(get_db)):
    db_quiz = db.query(model.Quiz).filter(model.Quiz.quizID == quiz_id).first()
    
    if not db_quiz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")
    
    db.delete(db_quiz)
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