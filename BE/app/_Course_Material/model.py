from sqlalchemy import Column, String, DateTime, Float, Integer, ForeignKey, Text, PrimaryKeyConstraint
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from ..database import Base

class CourseMaterialAssociation(Base):
    __tablename__ = "Course_Materials"

    courseID = Column(Integer, ForeignKey('Courses.courseID', ondelete="CASCADE"), nullable=False)
    materialID = Column(Integer, ForeignKey('Materials.materialID', ondelete="CASCADE"), nullable=False)

    __table_args__ = (
        PrimaryKeyConstraint('courseID', 'materialID'),
    )

    course = relationship("Course", back_populates="course_material")
    material = relationship("Material", back_populates="course_material")
