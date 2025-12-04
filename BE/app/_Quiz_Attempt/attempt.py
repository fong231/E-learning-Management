from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from . import model as AttemptModel, schema as AttemptSchema
from .._Quiz import model as QuizModel
from .._Student import model as StudentModel
from .._Customer import model as CustomerModel
from .._Question import model as QuestionModel


router = APIRouter(
    prefix="/quiz-attempts",
    tags=["Quiz Attempts"],
)

quiz_router = APIRouter(
    prefix="/quizzes",
    tags=["Quiz Attempts"],
)


def _serialize_attempt(db: Session, attempt: AttemptModel.QuizAttempt) -> AttemptSchema.QuizAttemptRead:
    student = (
        db.query(StudentModel.Student)
        .filter(StudentModel.Student.studentID == attempt.studentID)
        .first()
    )

    customer = None
    if student is not None:
        customer = (
            db.query(CustomerModel.Customer)
            .filter(CustomerModel.Customer.customerID == student.studentID)
            .first()
        )

    student_name = customer.fullname if customer else None
    started_at = attempt.started_at if getattr(attempt, "started_at", None) else datetime.utcnow()

    return AttemptSchema.QuizAttemptRead(
        attempt_id=attempt.attemptID,
        quiz_id=attempt.quizID,
        student_id=attempt.studentID,
        student_name=student_name,
        started_at=started_at,
        completed_at=attempt.completed_at,
        score=attempt.score,
        attempt_number=attempt.attempt_number,
    )


@router.post("/", response_model=AttemptSchema.QuizAttemptRead, status_code=status.HTTP_201_CREATED)
def start_quiz_attempt(payload: AttemptSchema.QuizAttemptCreate, db: Session = Depends(get_db)):
    quiz = db.query(QuizModel.Quiz).filter(QuizModel.Quiz.quizID == payload.quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")

    student = (
        db.query(StudentModel.Student)
        .filter(StudentModel.Student.studentID == payload.student_id)
        .first()
    )
    if not student:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found")

    existing_attempts = (
        db.query(AttemptModel.QuizAttempt)
        .filter(
            AttemptModel.QuizAttempt.quizID == payload.quiz_id,
            AttemptModel.QuizAttempt.studentID == payload.student_id,
        )
        .count()
    )

    attempt_number = existing_attempts + 1

    attempt = AttemptModel.QuizAttempt(
        quizID=payload.quiz_id,
        studentID=payload.student_id,
        started_at=datetime.utcnow(),
        attempt_number=attempt_number,
    )
    db.add(attempt)
    db.commit()
    db.refresh(attempt)

    return _serialize_attempt(db, attempt)


@router.post("/{attempt_id}/submit", response_model=AttemptSchema.QuizAttemptRead)
def submit_quiz_attempt(attempt_id: int, payload: AttemptSchema.QuizAttemptSubmit, db: Session = Depends(get_db)):
    attempt = (
        db.query(AttemptModel.QuizAttempt)
        .filter(AttemptModel.QuizAttempt.attemptID == attempt_id)
        .first()
    )
    if not attempt:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Attempt not found")

    questions = (
        db.query(QuestionModel.Question)
        .filter(QuestionModel.Question.quizID == attempt.quizID)
        .all()
    )

    total = len(questions)
    correct = 0

    answers = payload.answers or {}

    if total > 0:
        for q in questions:
            ans = answers.get(q.questionID)
            if ans is not None and ans == q.answer:
                correct += 1
        score = (correct / total) * 100.0
    else:
        score = 0.0

    attempt.score = score
    attempt.completed_at = datetime.utcnow()

    db.commit()
    db.refresh(attempt)

    return _serialize_attempt(db, attempt)


@quiz_router.get("/{quiz_id}/attempts", response_model=List[AttemptSchema.QuizAttemptRead])
def get_quiz_attempts(quiz_id: int, student_id: int | None = None, db: Session = Depends(get_db)):
    quiz = db.query(QuizModel.Quiz).filter(QuizModel.Quiz.quizID == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")

    query = db.query(AttemptModel.QuizAttempt).filter(AttemptModel.QuizAttempt.quizID == quiz_id)
    if student_id is not None:
        query = query.filter(AttemptModel.QuizAttempt.studentID == student_id)

    attempts = query.order_by(AttemptModel.QuizAttempt.started_at.asc()).all()

    return [_serialize_attempt(db, a) for a in attempts]


@quiz_router.get("/{quiz_id}/questions")
def get_quiz_questions(quiz_id: int, db: Session = Depends(get_db)):
    quiz = db.query(QuizModel.Quiz).filter(QuizModel.Quiz.quizID == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quiz not found")

    questions = (
        db.query(QuestionModel.Question)
        .filter(QuestionModel.Question.quizID == quiz_id)
        .all()
    )

    level_map = {
        "easy": "easy_question",
        "medium": "medium_question",
        "hard": "hard_question",
    }

    results = []
    for q in questions:
        results.append(
            {
                "question_id": q.questionID,
                "quiz_id": q.quizID,
                "question_text": "",
                "question_type": "multiple_choice",
                "level": level_map.get(getattr(q, "level", None), "medium_question"),
                "points": 1,
                "options": ["A", "B", "C", "D"],
                "correct_answer": getattr(q, "answer", None),
                "created_at": datetime.utcnow().isoformat(),
            }
        )

    return {"questions": results}
