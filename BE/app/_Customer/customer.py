import os
import shutil
import uuid
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
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

BASE_URL = "http://10.0.2.2:8000/uploads"
# BASE_URL = "http://localhost:8000/uploads"


CURRENT_DIR = os.path.dirname(os.path.abspath(__file__)) 
UPLOAD_DIR = os.path.join(CURRENT_DIR, '..', '..', 'uploads')

if not os.path.exists(UPLOAD_DIR):
    try:
        os.makedirs(UPLOAD_DIR, exist_ok=True)
        print(f"Created UPLOAD_DIR: {UPLOAD_DIR}")
    except Exception as e:
        # Xử lý lỗi nếu không có quyền tạo thư mục
        print(f"ERROR: Could not create UPLOAD_DIR: {e}")
        # Bạn có thể cân nhắc raise lỗi tại đây nếu đây là lỗi nghiêm trọng

router = APIRouter(
    prefix="/customers",
    tags=["Customers"],
)

def save_avatar_file(file_upload: UploadFile, customer_id: str):
    file_extension = os.path.splitext(file_upload.filename)[1]
    unique_filename = f"customer_{customer_id}_{uuid.uuid4()}{file_extension}"
    file_path_on_disk = os.path.join(UPLOAD_DIR, unique_filename)

    try:
        with open(file_path_on_disk, "wb") as buffer:
            shutil.copyfileobj(file_upload.file, buffer)
        
        # return f"{BASE_URL}{unique_filename}"
        return f"/{unique_filename}"
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error saving avatar into disk: {e}"
        )
    finally:
        file_upload.file.close()

def create_customer(customer: schema.CustomerCreate, db: Session):
    email = customer.email
    email_exist = db.query(model.Customer).filter(model.Customer.fullname == email).first()
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
# @router.post("/", status_code=status.HTTP_201_CREATED)
# def create(
#     customer: schema.CustomerCreate,
#     avatar: UploadFile = File(None, description="Customer Avatar Image"), 
#     db: Session = Depends(get_db)
# ):
#     db_customer = create_customer(customer, db)
    
#     if avatar:
#         avatar_url = save_avatar_file(avatar, db_customer.customerID)
#         db_customer.avatar = avatar_url
#     else:
#         db_customer.avatar = ''
        
#     try:
#         db.commit()
#         db.refresh(db_customer)
#     except Exception as e:
#         db.rollback()
#         raise HTTPException(
#             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#             detail=f"Error updating avatar URL: {e}"
#         )
        
    
#     return {"message": "Customer created successfully"}

# read customer
@router.get("/{customer_id}/profile", response_model=schema.CustomerRead)
def read(customer_id : int, db : Session = Depends(get_db)):
    customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    if customer.avatar:
        if customer.avatar.startswith('/'):
            # customer.avatar = f"{BASE_URL}{customer.avatar}"
            customer.avatar = customer.avatar
    
    return customer

# update customer
@router.patch("/{customer_id}/profile", response_model=schema.CustomerRead)
def update(
    customer_id : int, 
    customer_data: schema.CustomerUpdate = Depends(schema.CustomerUpdate.as_form),
    avatar: UploadFile = File(None, description="Customer Avatar Image"), 
    db : Session = Depends(get_db)
):
    db_customer = db.query(model.Customer).filter(model.Customer.customerID == customer_id).first()
    
    if not db_customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    
    email = customer_data.email
    fullname = customer_data.fullname
    
    if email:
        email_exist = (
            db.query(model.Customer)
            .filter(model.Customer.email == email)
            .filter(model.Customer.customerID != customer_id)
            .first()
        )
        if email_exist:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Customer with email '{email}' already exists."
            )

    if fullname:
        fullname_exist = (
            db.query(model.Customer)
            .filter(model.Customer.fullname == fullname)
            .filter(model.Customer.customerID != customer_id)
            .first()
        )
        if fullname_exist:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Customer with username '{fullname}' already exists."
            )
        
    update_data = customer_data.model_dump(exclude_unset=True, exclude_none=True)
    
    if avatar and avatar.filename: 
        try:
            new_avatar_url = save_avatar_file(avatar, customer_id)
            update_data['avatar'] = new_avatar_url
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error saving new avatar file: {e}"
            )
    
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