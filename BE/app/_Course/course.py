from typing import Dict, List
from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session, joinedload
from ..database import get_db 
from . import schema, model
from .._Semester import model as SemesterModel
from .._Instructor import model as InstructorModel
from .._Group import model as GroupModel
from .._Learning_Content import model as ContentModel
from .._Course_Material import model as Course_MaterialModel
from .._Material import model as MaterialModel
from .._File_Image import model as FileImageModel
from .._Student_Group.model import StudentGroupAssociation
from .._Group.schema import GroupOutput
from .._Customer.model import Customer
from .._Student.model import Student
from .._Student.schema import StudentOutput

router = APIRouter(
    prefix="/courses",
    tags=["Courses"],
)

# create course
@router.post("/", status_code=status.HTTP_201_CREATED)
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
    return {"message": "Course created successfully"}

# read course
@router.get("/{course_id}", response_model=schema.CourseRead)
def read(course_id : int, db : Session = Depends(get_db)):
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not course:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Course not found")
    
    return course

# read all courses
@router.get("/", response_model=List[schema.CourseRead])
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
    content_id: int,
    db: Session = Depends(get_db)
):
    result = (
        db.query(
            ContentModel.LearningContent.contentID,
            model.Course.courseID,
            model.Course.course_name,
            ContentModel.LearningContent.title,
            ContentModel.LearningContent.description,
            FileImageModel.FileImage.path.label("content_url"), 
            # FileImageModel.FileImage.upload_at.label("upload_at"),
        )
        .select_from(ContentModel.LearningContent) 

        .join(MaterialModel.Material, ContentModel.LearningContent.contentID == MaterialModel.Material.materialID)
        .join(Course_MaterialModel.CourseMaterialAssociation, MaterialModel.Material.materialID == Course_MaterialModel.CourseMaterialAssociation.materialID)

        # 2. Join to Course
        .join(model.Course, Course_MaterialModel.CourseMaterialAssociation.courseID == model.Course.courseID)

        # 3. Outer Join to File/Image
        .outerjoin(FileImageModel.FileImage, ContentModel.LearningContent.contentID == FileImageModel.FileImage.contentID) 
        
        .filter(model.Course.courseID == course_id)
        .filter(ContentModel.LearningContent.contentID == content_id)
        .first()
    )

    if not result:
        content_exists = db.query(ContentModel.LearningContent).filter(ContentModel.LearningContent.contentID == content_id).first()
        
        if not content_exists:
            detail_msg = f"Learning Content with ID {content_id} not found."
        else:
            detail_msg = f"Learning Content with ID {content_id} is not associated with Course {course_id}."

        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=detail_msg
        )

    content_data = {
        "content_id": result.contentID,
        "course_id": result.courseID,
        "course_name": result.course_name,
        "title": result.title,
        "description": result.description,
        # "content_type": result.content_type, 
        "content_url": result.content_url,
        # "session_number": result.session_number, 
        
        # "created_at": result.created_at.isoformat() + "Z" if result.created_at else None,
        # Use LearningContent's updated_at if available, otherwise use FileImage's upload_at
        # "updated_at": result.updated_at.isoformat() + "Z" if result.updated_at else (result.upload_at.isoformat() + "Z" if result.upload_at else None), 
    }

    return {"content": [content_data]}

@router.get("/{course_id}/groups", response_model=List[GroupOutput])
def get_groups_by_course(course_id: int, db: Session = Depends(get_db)):
    
    course = db.query(model.Course).filter(model.Course.courseID == course_id).first()
    
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
        
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