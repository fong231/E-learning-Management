from sqlalchemy import Column, Numeric, String, DateTime, Float, Integer, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base


class Question(Base):
    __tablename__ = "Questions"

    questionID = Column(Integer, primary_key=True, index=True)

    # New schema fields
    question_text = Column(Text, nullable=False)
    answer_1 = Column(Text, nullable=False)
    answer_2 = Column(Text, nullable=False)
    answer_3 = Column(Text, nullable=False)
    answer_4 = Column(Text, nullable=False)

    level = Column(
        Enum(
            "easy_question",
            "medium_question",
            "hard_question",
            name="question_levels",
        ),
        nullable=False,
    )

    correct_answer = Column(
        Enum("A", "B", "C", "D", name="answer_options"),
        nullable=False,
    )

    quizID = Column(Integer, ForeignKey('Quizzes.quizID', ondelete="SET NULL"), nullable=True)

    # relationship
    quiz = relationship("Quiz", back_populates="question")