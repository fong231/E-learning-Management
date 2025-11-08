from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from ..config import CONTENT_BASE_URL, GROUP_BASE_URL

router = APIRouter(
    prefix="/quizzes",
    tags=["Quizzes"],
)

# create quiz
@router.post("/", status_code=201)
def create(quiz: schema.QuizCreate, db: Session = Depends(get_db)):
    db_quiz = model.Quiz(
        duration = quiz.duration,
        open_time = quiz.open_time,
        close_time = quiz.close_time,
        easy_questions = quiz.easy_questions,
        medium_questions = quiz.medium_questions,
        hard_questions = quiz.hard_questions,
        number_of_attempts = quiz.number_of_attempts
    )
    
    db.add(db_quiz)
    db.commit()
    db.refresh(db_quiz)
    return {"message": "Quiz created successfully"}

# read quiz
@router.get("/{quiz_id}", response_model=schema.QuizRead)
def read(quiz_id : int, db : Session = Depends(get_db)):
    quiz = db.query(model.Quiz).filter(model.Quiz.quizID == quiz_id).first()
    
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    
    return quiz

# update quiz
@router.patch("/{quiz_id}", response_model=schema.QuizUpdate)
def update(quiz_id : int, quiz_data: schema.QuizUpdate, db : Session = Depends(get_db)):
    db_quiz = db.query(model.Quiz).filter(model.Quiz.quizID == quiz_id).first()
    
    if not db_quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    
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