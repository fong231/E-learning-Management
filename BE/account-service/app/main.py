from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .dependencies.conditional_auth import conditional_get_current_user
from ._Account import account
from ._Customer import customer
from ._Authenticate import authenticate

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Account Service")

#TODO fix the db commit issue

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