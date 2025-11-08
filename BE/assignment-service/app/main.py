from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .dependencies.conditional_auth import conditional_get_current_user
from ._Assignment import assignment

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Assignment Service")

# app.include_router(semester.router, dependencies=[Depends(conditional_get_current_user)])
app.include_router(assignment.router)

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