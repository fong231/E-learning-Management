import os
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from .database import engine, Base
# from ._Account import account
from ._Announcement import announcement
from ._Assignment import assignment
from ._Authenticate import authenticate
from ._Course import course
from ._Course_Material import course_material
from ._Customer import customer
from ._File_Image import file_image
from ._Group import group
from ._Instructor import instructor
from ._Learning_Content import learning_content
from ._Material import material
from ._Message import message
from ._Notification import notification
from ._Question import question
from ._Quiz import quiz
from ._Quiz_Attempt import attempt
from ._Semester import semester
from ._Student import student
from ._Student_Group import student_group
from ._Student_Score import student_score
from ._Submission import submission
from ._Topic import topic

from .dependencies.auth import get_current_active_user

Base.metadata.create_all(bind=engine)

app = FastAPI(title="E-Learning Backend")

auth_dependency = [Depends(get_current_active_user)]

current_file_dir = os.path.dirname(os.path.abspath(__file__))

STATIC_DIR = os.path.join(current_file_dir, '..', 'uploads') 

app.mount("/uploads", StaticFiles(directory=STATIC_DIR), name="uploads")

app.include_router(customer.router, dependencies=auth_dependency)
# app.include_router(account.router, dependencies=auth_dependency)
app.include_router(authenticate.router)
app.include_router(announcement.router, dependencies=auth_dependency)
app.include_router(announcement.comment_router, dependencies=auth_dependency)
app.include_router(assignment.router, dependencies=auth_dependency)
app.include_router(course.router, dependencies=auth_dependency)
app.include_router(course_material.router, dependencies=auth_dependency)
app.include_router(file_image.router, dependencies=auth_dependency)
app.include_router(group.router, dependencies=auth_dependency)
app.include_router(instructor.router, dependencies=auth_dependency)
app.include_router(learning_content.router, dependencies=auth_dependency)
app.include_router(material.router, dependencies=auth_dependency)
app.include_router(question.router, dependencies=auth_dependency)
app.include_router(quiz.router, dependencies=auth_dependency)
app.include_router(attempt.router, dependencies=auth_dependency)
app.include_router(attempt.quiz_router, dependencies=auth_dependency)
app.include_router(semester.router, dependencies=auth_dependency)
app.include_router(student.router, dependencies=auth_dependency)
app.include_router(student_group.router, dependencies=auth_dependency)
app.include_router(student_score.router, dependencies=auth_dependency)
app.include_router(topic.router, dependencies=auth_dependency)
app.include_router(topic.chat_router, dependencies=auth_dependency)
app.include_router(message.router, dependencies=auth_dependency)
app.include_router(message.user_router, dependencies=auth_dependency)
app.include_router(notification.student_router, dependencies=auth_dependency)
app.include_router(notification.notification_router, dependencies=auth_dependency)
app.include_router(submission.router, dependencies=auth_dependency)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.get("/")
def read_root():
    return {"message": "This is Backend API"}