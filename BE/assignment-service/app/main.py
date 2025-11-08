from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .dependencies.conditional_auth import conditional_get_current_user
from ._Assignment import assignment
from ._Student_Score import student_score
from _Quiz import quiz
from _Question import question

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Assignment Service")

# app.include_router(semester.router, dependencies=[Depends(conditional_get_current_user)])
# TODO , add auth with jwt
app.include_router(assignment.router)
app.include_router(student_score.router)
app.include_router(quiz.router)
app.include_router(question.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "This is Assignment Service API"}