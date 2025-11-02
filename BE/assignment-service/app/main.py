from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from .database import SessionLocal, engine, Base
from . import model, schema
import uuid, httpx

Base.metadata.create_all(bind=engine)

app = FastAPI(title="ticket service")

EVENT_SERVICE_URL = "http://localhost:8001/events/"

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/tickets/", response_model=schema.TicketRead)
def create_ticket(ticket: schema.TicketCreate, db: Session = Depends(get_db)):
    # Kiểm tra event tồn tại bằng REST call
    response = httpx.get(f"{EVENT_SERVICE_URL}{ticket.event_id}")
    if response.status_code != 200:
        raise HTTPException(status_code=404, detail="Event not found")

    db_ticket = model.Ticket(
        event_id=ticket.event_id,
        user_id=ticket.user_id,
        qr_code=str(uuid.uuid4())
    )
    db.add(db_ticket)
    db.commit()
    db.refresh(db_ticket)
    return db_ticket
