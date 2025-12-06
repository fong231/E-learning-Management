from typing import List
from datetime import datetime
from typing import Dict, List
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
import requests
from sqlalchemy.orm import Session, joinedload
import os
import shutil
import uuid
from ..database import get_db 
from . import schema, model
from .._Semester import model as SemesterModel
from .._Instructor import model as InstructorModel
from .._Group import model as GroupModel
from .._Learning_Content import model as ContentModel
from .._Course_Material import model as Course_MaterialModel
from .._Material import model as MaterialModel
from .._File_Image import model as FileImageModel
from .._Assignment import model as AssignmentModel
from .._Quiz import model as QuizModel
from .._Student_Score import model as StudentScoreModel
from .._Topic import model as TopicModel
from .._Announcement import model as AnnouncementModel
from .._Customer import model as CustomerModel
from ..dependencies.auth import get_current_active_user
# from .._Instructor import 
from .._Student_Group.model import StudentGroupAssociation
from .._Group.schema import GroupOutput
from .._Customer.model import Customer
from .._Student.model import Student
from .._Student.schema import StudentOutput

router = APIRouter(
    prefix="/courses",
    tags=["Courses"],
)

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
MATERIAL_UPLOAD_DIR = os.path.join(CURRENT_DIR, "..", "..", "uploads", "materials")

os.makedirs(MATERIAL_UPLOAD_DIR, exist_ok=True)

# create course
@router.post("", status_code=status.HTTP_201_CREATED)
def create(course: schema.CourseCreate, db: Session = Depends(get_db)):
    instructor_id = course.instructorID
    
    instructor = db.query(InstructorModel.Instructor).filter(
        InstructorModel.Instructor.instructorID == instructor_id
    ).first()
    
    if not instructor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Instructor not found")
        
    semester_id = course.semesterID
    if semester_id is not None:
        semester = db.query(SemesterModel.Semester).filter(SemesterModel.Semester.semesterID == semester_id).first()
        
        if not semester:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Semester with ID '{semester_id}' not found."
            )
    
    db_course = model.Course(**course.model_dump())
    
    db.add(db_course)
    db.commit()
    db.refresh(db_course)

    course_read = schema.CourseRead.from_orm(db_course)
    return {"message": "Course created successfully", "course": course_read}

# read course
@router.get("/{course_id}", response_model=schema.CourseRead)
def read(course_id : int, db : Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    return course

# read all courses
@router.get("", response_model=List[schema.CourseRead])
def read_all(db : Session = Depends(get_db)):
    courses = db.query(model.Course).all()
    
    if not courses:
        return []
    
    return courses

# # read groups for this course
# @router.get("/{course_id}/groups")
# def read_groups_in_course(course_id : int, db : Session = Depends(get_db)):
#     course = db.query(model.Course).filter(
#         model.Course.courseID == course_id
#     ).first()
    
#     if not course:
#         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="course not found")
    
#     groups = (
#         db.query(GroupModel.Group)
#         .filter(GroupModel.Group.courseID == course_id)
#         .all()
#     )
    
#     groups_data = []
    
#     for group in groups:
#         student_count = len(group.student_association)

#         groups_data.append(
#             {
#                 "group_id": group.groupID,
#                 "course_id": group.courseID,
#                 "course_name": course.course_name,
#                 "group_name": f"Group {group.id}",
#                 "students": student_count,
#                 # "created_at": "2024-01-01T00:00:00Z",
#             }
#         )

#     return {"groups": groups_data}

# read topics for this course
@router.get("/{course_id}/topics")
def get_course_topics(course_id: int, db: Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")

    topics = (
        db.query(TopicModel.Topic)
        .filter(TopicModel.Topic.courseID == course_id)
        .all()
    )

    result = []

    for topic in topics:
        reply_count = (
            db.query(TopicModel.TopicChat)
            .filter(TopicModel.TopicChat.topicID == topic.topicID)
            .count()
        )

        instructor_id = course.instructorID
        instructor_name = None
        instructor_role = "instructor"

        if instructor_id is not None:
            customer = (
                db.query(CustomerModel.Customer)
                .filter(CustomerModel.Customer.customerID == instructor_id)
                .first()
            )
            if customer:
                instructor_name = customer.fullname
                instructor_role = customer.role

        created_at = topic.created_at if getattr(topic, "created_at", None) else datetime.utcnow()

        result.append(
            {
                "topic_id": topic.topicID,
                "course_id": course.courseID,
                "course_name": course.course_name,
                "creator_id": instructor_id,
                "creator_name": instructor_name,
                "creator_role": instructor_role,
                "title": topic.title,
                "content": topic.description or "",
                "view_count": reply_count,
                "reply_count": reply_count,
                "created_at": created_at.isoformat(),
                "updated_at": None,
            }
        )

    return {"topics": result}

# read announcements for this course
@router.get("/{course_id}/announcements")
def get_course_announcements(course_id: int, db: Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")

    rows = (
        db.query(
            AnnouncementModel.Announcement.announcementID.label("announcement_id"),
            model.Course.courseID.label("course_id"),
            model.Course.course_name.label("course_name"),
            ContentModel.LearningContent.title.label("title"),
            ContentModel.LearningContent.description.label("content"),
            InstructorModel.Instructor.instructorID.label("instructor_id"),
            CustomerModel.Customer.fullname.label("instructor_name"),
        )
        .join(GroupModel.Group, AnnouncementModel.Announcement.groupID == GroupModel.Group.groupID)
        .join(model.Course, GroupModel.Group.courseID == model.Course.courseID)
        .join(
            ContentModel.LearningContent,
            AnnouncementModel.Announcement.announcementID == ContentModel.LearningContent.contentID,
        )
        .outerjoin(
            InstructorModel.Instructor,
            model.Course.instructorID == InstructorModel.Instructor.instructorID,
        )
        .outerjoin(
            CustomerModel.Customer,
            InstructorModel.Instructor.instructorID == CustomerModel.Customer.customerID,
        )
        .filter(model.Course.courseID == course_id)
        .all()
    )

    result = []
    for row in rows:
        result.append(
            {
                "announcement_id": row.announcement_id,
                "course_id": row.course_id,
                "course_name": row.course_name,
                "instructor_id": row.instructor_id,
                "instructor_name": row.instructor_name,
                "title": row.title,
                "content": row.content,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": None,
            }
        )

    return {"announcements": result}

# read assignments for this course
@router.get("/{course_id}/assignments")
def get_course_assignments(course_id: int, db: Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")

    rows = (
        db.query(
            AssignmentModel.Assignment.assignmentID.label("assignment_id"),
            GroupModel.Group.groupID.label("group_id"),
            model.Course.courseID.label("course_id"),
            model.Course.course_name.label("course_name"),
            AssignmentModel.Assignment.title.label("title"),
            AssignmentModel.Assignment.description.label("description"),
            AssignmentModel.Assignment.deadline.label("deadline"),
            AssignmentModel.Assignment.late_deadline.label("late_deadline"),
            AssignmentModel.Assignment.size_limit.label("size_limit"),
            AssignmentModel.Assignment.file_format.label("file_format"),
        )
        .join(GroupModel.Group, AssignmentModel.Assignment.groupID == GroupModel.Group.groupID)
        .join(model.Course, GroupModel.Group.courseID == model.Course.courseID)
        .filter(model.Course.courseID == course_id)
        .all()
    )

    assignments = []
    for row in rows:
        assignments.append(
            {
                "assignment_id": row.assignment_id,
                "course_id": row.course_id,
                "course_name": row.course_name,
                "group_id": row.group_id,
                "title": row.title,
                "description": row.description,
                "deadline": row.deadline.isoformat() if row.deadline else None,
                "late_deadline": row.late_deadline.isoformat() if row.late_deadline else None,
                "size_limit": str(row.size_limit) if row.size_limit is not None else None,
                "file_format": row.file_format,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": None,
                "files_url": [],
            }
        )

    return {"assignments": assignments}

# read quizzes for this course
@router.get("/{course_id}/quizzes")
def get_course_quizzes(course_id: int, db: Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")

    rows = (
        db.query(
            QuizModel.Quiz.quizID.label("quiz_id"),
            model.Course.courseID.label("course_id"),
            model.Course.course_name.label("course_name"),
            QuizModel.Quiz.duration.label("duration"),
            QuizModel.Quiz.open_time.label("start_time"),
            QuizModel.Quiz.close_time.label("end_time"),
            QuizModel.Quiz.number_of_attempts.label("number_of_attempts"),
        )
        .join(
            StudentScoreModel.StudentScore,
            StudentScoreModel.StudentScore.quizID == QuizModel.Quiz.quizID,
        )
        .join(GroupModel.Group, StudentScoreModel.StudentScore.groupID == GroupModel.Group.groupID)
        .join(model.Course, GroupModel.Group.courseID == model.Course.courseID)
        .filter(model.Course.courseID == course_id)
        .all()
    )

    quizzes = []
    seen_quiz_ids = set()
    for row in rows:
        if row.quiz_id in seen_quiz_ids:
            continue

        seen_quiz_ids.add(row.quiz_id)

        quizzes.append(
            {
                "quiz_id": row.quiz_id,
                "course_id": row.course_id,
                "course_name": row.course_name,
                "title": f"Quiz {row.quiz_id}",
                "duration": row.duration,
                "start_time": row.start_time.isoformat() if row.start_time else None,
                "end_time": row.end_time.isoformat() if row.end_time else None,
                "number_of_attempts": row.number_of_attempts,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": None,
            }
        )

    return {"quizzes": quizzes}

# update course
@router.patch("/{course_id}", response_model=schema.CourseRead)
def update(course_id : int, course_data: schema.CourseUpdate, db : Session = Depends(get_db)):
    db_course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not db_course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    semester_id = course_data.semesterID
    if semester_id is not None:
        semester = db.query(SemesterModel.Semester).filter(SemesterModel.Semester.semesterID == semester_id).first()
        
        if not semester:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Semester with ID '{semester_id}' not found."
            )
    
    update_data = course_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_course, key, value)

    db.commit()
    db.refresh(db_course)
    
    return db_course

@router.put("/{course_id}")
def put_update(course_id: int, course_data: schema.CourseUpdate, db: Session = Depends(get_db)):
    updated = update(course_id, course_data, db)
    return {"course": updated}

# delete course
@router.delete("/{course_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(course_id : int, db : Session = Depends(get_db)):
    db_course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not db_course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    db.delete(db_course)
    db.commit()
    
    return {"message": "Course deleted successfully"}

# get course content
@router.get("/{course_id}/content")
def get_course_content(
    course_id: int,
    content_id: int = None,
    db: Session = Depends(get_db),
):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")

    base_query = (
        db.query(
            ContentModel.LearningContent.contentID.label("content_id"),
            model.Course.courseID.label("course_id"),
            model.Course.course_name.label("course_name"),
            ContentModel.LearningContent.title,
            ContentModel.LearningContent.description,
            FileImageModel.FileImage.path.label("content_url"),
        )
        .select_from(ContentModel.LearningContent)
        .join(
            MaterialModel.Material,
            ContentModel.LearningContent.contentID == MaterialModel.Material.materialID,
        )
        .join(
            Course_MaterialModel.CourseMaterialAssociation,
            MaterialModel.Material.materialID
            == Course_MaterialModel.CourseMaterialAssociation.materialID,
        )
        .join(
            model.Course,
            Course_MaterialModel.CourseMaterialAssociation.courseID
            == model.Course.courseID,
        )
        .outerjoin(
            FileImageModel.FileImage,
            ContentModel.LearningContent.contentID == FileImageModel.FileImage.contentID,
        )
        .filter(model.Course.courseID == course_id)
    )

    if content_id is not None:
        result = base_query.filter(
            ContentModel.LearningContent.contentID == content_id
        ).first()

        if not result:
            content_exists = (
                db.query(ContentModel.LearningContent)
                .filter(ContentModel.LearningContent.contentID == content_id)
                .first()
            )

            if not content_exists:
                detail_msg = f"Learning Content with ID {content_id} not found."
            else:
                detail_msg = (
                    f"Learning Content with ID {content_id} is not associated with Course {course_id}."
                )

            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=detail_msg,
            )

        items = [result]
    else:
        items = base_query.all()

    content_list = []
    session_number = 1
    for row in items:
        content_list.append(
            {
                "content_id": row.content_id,
                "course_id": row.course_id,
                "course_name": row.course_name,
                "title": row.title,
                "description": row.description,
                "content_type": "document",
                "content_url": row.content_url,
                "session_number": session_number,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": None,
            }
        )
        session_number += 1

    return {"content": content_list}

from fastapi import UploadFile, File
from fastapi import status
from uuid import uuid4
import os
import shutil
from pathlib import Path

MATERIAL_UPLOAD_DIR = Path(__file__).parent / "uploads/materials"

@router.post("/{course_id}/materials/files")
async def upload_course_material_file(
    course_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_active_user),
):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")

    original_filename = file.filename or "material"
    title = os.path.splitext(original_filename)[0]

    db_content = ContentModel.LearningContent(
        title=title,
        description=None,
    )
    db.add(db_content)
    db.commit()
    db.refresh(db_content)

    file_extension = os.path.splitext(file.filename or "")[1]
    unique_filename = f"material_{course_id}_{db_content.contentID}_{uuid4()}{file_extension}"
    file_path_on_disk = os.path.join(MATERIAL_UPLOAD_DIR, unique_filename)

    try:
        with open(file_path_on_disk, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save file to disk: {e}",
        )
    finally:
        file.file.close()

    relative_url = f"/uploads/materials/{unique_filename}"

    db_file = FileImageModel.FileImage(
        contentID=db_content.contentID,
        path=relative_url,
        uploaded_at=datetime.utcnow(),
        uploaded_by=current_user_id,
    )
    db.add(db_file)

    db_material = MaterialModel.Material(
        materialID=db_content.contentID,
        title=title,
        description=None,
    )
    db.add(db_material)

    db_association = Course_MaterialModel.CourseMaterialAssociation(
        courseID=course_id,
        materialID=db_material.materialID,
    )
    db.add(db_association)

    db.commit()
    db.refresh(db_file)

    return {
        "content_id": db_content.contentID,
        "file_url": relative_url,
        "title": title,
    }

@router.get("/{course_id}/groups", response_model=List[GroupOutput])
def get_groups_by_course(course_id: int, db: Session = Depends(get_db)):
    
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    course_name = course.course_name
    
    groups_query = (
        db.query(GroupModel.Group)
        .filter(GroupModel.Group.courseID == course_id)
        .options(
            joinedload(GroupModel.Group.student_association) 
        )
        .all()
    )

    if not groups_query:
        return []

    all_student_ids = []
    group_to_student_ids_map: Dict[int, List[int]] = {}
    
    for group in groups_query:
        student_ids_in_group = [assoc.studentID for assoc in group.student_association]
        group_to_student_ids_map[group.groupID] = student_ids_in_group
        all_student_ids.extend(student_ids_in_group)

    unique_student_ids = list(set(all_student_ids))
    student_map: Dict[int, Customer] = {}
    
    if unique_student_ids:
        students_data = (
            db.query(Customer)
            .join(Student, Student.studentID == Customer.customerID)
            .filter(Customer.customerID.in_(unique_student_ids))
            .all()
        )
        student_map = {s.customerID: s for s in students_data}
    
    results: List[GroupOutput] = []
    
    for group in groups_query:
        group_id = group.groupID
        group_display_name = f"{course_name} - Group {group.id}"
        
        students_list: List[StudentOutput] = []
        current_student_ids = group_to_student_ids_map.get(group_id, [])
        
        for student_id in current_student_ids:
            customer = student_map.get(student_id)
            if customer:
                student_output = StudentOutput.model_validate(customer)
                student_output.groupId = group_id
                student_output.groupName = group_display_name
                students_list.append(student_output)
        
        results.append(GroupOutput(
            id=group.id,
            courseId=group.courseID,
            courseName=course_name,
            groupName=group_display_name,
            students=students_list
        ))
    
    
    return results
