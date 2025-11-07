from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from ._Semester import semester
from ._Course import course
from ._File_Image import file_image
from ._Group import group
from ._Learning_Content import learning_content
from ._Student_Group import student_group
from .dependencies.conditional_auth import conditional_get_current_user

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Course Service")

# app.include_router(semester.router, dependencies=[Depends(conditional_get_current_user)])
app.include_router(semester.router)
app.include_router(course.router)
app.include_router(file_image.router)
app.include_router(group.router)
app.include_router(learning_content.router)
app.include_router(student_group.router)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "This is Coure Service API"}