from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from ._Account import account
from ._Annoucement import annoucement
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
from ._Question import question
from ._Question import question
from ._Quiz import quiz
from ._Semester import semester
from ._Student import student
from ._Student_Group import student_group
from ._Student_Score import student_score

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Account Service")

app.include_router(customer.router)
app.include_router(account.router)
app.include_router(authenticate.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "This is Account Service API"}