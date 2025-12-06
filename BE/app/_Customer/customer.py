from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy import or_
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Semester import model as SemesterModel
from .._Semester import schema as SemesterSchema
from .._Course.model import Course
from .._Group.model import Group
from .._Student_Group.model import StudentGroupAssociation

router = APIRouter(
    prefix="/customers",
    tags=["Customers"],
)

def create_customer(customer: schema.CustomerCreate, db: Session):
    email = customer.email
    email_exist = db.query(model.Customer).filter(model.Customer.email == email).first()
    if email_exist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Customer with email '{email}' already exists."
        )
    
    db_customer = model.Customer(**customer.model_dump())
    
    db.add(db_customer)
    db.commit()
    db.refresh(db_customer)
    return db_customer

# create customer
@router.post("/", status_code=status.HTTP_201_CREATED)
def create(customer: schema.CustomerCreate, db: Session = Depends(get_db)):

    create_customer(customer, db)
    
    return {"message": "Customer created successfully"}

# read customer
@router.get("/{customer_id}", response_model=schema.CustomerRead)
def read(customer_id : int, db : Session = Depends(get_db)):
    customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    return customer

# update customer
@router.patch("/{customer_id}", response_model=schema.CustomerRead)
def update(customer_id : int, customer_data: schema.CustomerUpdate, db : Session = Depends(get_db)):
    db_customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    email = db_customer.email
    email_exist = db.query(model.Customer).filter(model.Customer.email == email).first()
    if email_exist:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Customer with email '{email}' already exists."
        )
    
    update_data = customer_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_customer, key, value)

    db.commit()
    db.refresh(db_customer)
    
    return db_customer
    
# delete customer
@router.delete("/{customer_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(customer_id : int, db : Session = Depends(get_db)):
    db_customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    db.delete(db_customer)
    db.commit()
    
    return

# get customer semester
@router.get("/{customer_id}/semester", response_model=list[SemesterSchema.SemesterRead])
def get_semesters(customer_id: int, db: Session = Depends(get_db)):
    if not db.get(model.Customer, customer_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")

    is_instructor = Course.instructorID == customer_id

    is_student = db.query(Group.courseID).join(
        StudentGroupAssociation, 
        StudentGroupAssociation.groupID == Group.groupID
    ).filter(
        StudentGroupAssociation.studentID == customer_id
    ).subquery()

    semesters = db.query(SemesterModel.Semester).distinct().join(
        Course, 
        Course.semesterID == SemesterModel.Semester.semesterID
    ).filter(
        or_(
            is_instructor,
            Course.courseID.in_(is_student)
        )
    ).all()
    
    return semesters