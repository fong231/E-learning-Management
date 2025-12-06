from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from datetime import datetime
from ..database import get_db 
from . import schema, model
from .._Quiz import model as QuizModel

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

    options = [
        getattr(db_question, "answer_1", ""),
        getattr(db_question, "answer_2", ""),
        getattr(db_question, "answer_3", ""),
        getattr(db_question, "answer_4", ""),
    ]

    return {
        "question": {
            "question_id": db_question.questionID,
            "quiz_id": db_question.quizID,
            "question_text": getattr(db_question, "question_text", ""),
            "question_type": "multiple_choice",
            "level": getattr(db_question, "level", "medium_question"),
            "points": 1,
            "options": options,
            "correct_answer": getattr(db_question, "correct_answer", None),
            "created_at": datetime.utcnow().isoformat(),
        }
    }

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

# update question (PUT alias)
@router.put("/{question_id}")
def put_update(question_id: int, question_data: schema.QuestionUpdate, db: Session = Depends(get_db)):
    updated = update(question_id, question_data, db)
    return {"question": updated}

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