from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from . import model as SubmissionModel, schema as SubmissionSchema
from .._Student import model as StudentModel
from .._Customer import model as CustomerModel


router = APIRouter(
    prefix="/submissions",
    tags=["Submissions"],
)


def _serialize_submission(db: Session, sub: SubmissionModel.Submission) -> SubmissionSchema.SubmissionRead:
    student = (
        db.query(StudentModel.Student)
        .filter(StudentModel.Student.studentID == sub.studentID)
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
    submitted_at = sub.submitted_at if getattr(sub, "submitted_at", None) else datetime.utcnow()

    return SubmissionSchema.SubmissionRead(
        submission_id=sub.submissionID,
        assignment_id=sub.assignmentID,
        student_id=sub.studentID,
        student_name=student_name,
        submission_text=sub.submission_text,
        file_url=sub.file_url,
        submitted_at=submitted_at,
        score=sub.score,
        feedback=sub.feedback,
        graded_at=sub.graded_at,
    )


@router.post("/", response_model=SubmissionSchema.SubmissionRead, status_code=status.HTTP_201_CREATED)
def create_submission(payload: SubmissionSchema.SubmissionCreate, db: Session = Depends(get_db)):
    # Ensure student exists
    student = (
        db.query(StudentModel.Student)
        .filter(StudentModel.Student.studentID == payload.student_id)
        .first()
    )
    if not student:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student not found")

    db_submission = SubmissionModel.Submission(
        assignmentID=payload.assignment_id,
        studentID=payload.student_id,
        submission_text=payload.submission_text,
        file_url=payload.file_url,
        submitted_at=datetime.utcnow(),
    )

    db.add(db_submission)
    db.commit()
    db.refresh(db_submission)

    return _serialize_submission(db, db_submission)


@router.put("/{submission_id}/grade", response_model=SubmissionSchema.SubmissionRead)
def grade_submission(submission_id: int, payload: SubmissionSchema.SubmissionGradeUpdate, db: Session = Depends(get_db)):
    db_submission = (
        db.query(SubmissionModel.Submission)
        .filter(SubmissionModel.Submission.submissionID == submission_id)
        .first()
    )

    if not db_submission:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Submission not found")

    db_submission.score = payload.score
    db_submission.feedback = payload.feedback
    db_submission.graded_at = datetime.utcnow()

    db.commit()
    db.refresh(db_submission)

    return _serialize_submission(db, db_submission)
