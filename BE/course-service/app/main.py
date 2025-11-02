from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from .database import SessionLocal, engine, Base
from . import model, schema
import uuid

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Event Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# create event
@app.post("/events/", response_model=schema.EventRead)
def create_event(event: schema.EventCreate, db: Session = Depends(get_db)):
    db_event = model.Event(
        id=str(uuid.uuid4()),
        name=event.name,
        description=event.description,
        start_time=event.start_time,
        end_time=event.end_time
    )
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event

# get event list
@app.get("/events/", response_model=list[schema.EventRead])
def read_events(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    events = db.query(model.Event).offset(skip).limit(limit).all()
    return events

@app.get("/events/{event_id}", response_model=schema.EventRead)
def get_event(event_id: str, db: Session = Depends(get_db)):
    event = db.query(model.Event).filter(model.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event
