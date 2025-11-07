from fastapi import APIRouter, Depends, HTTPException, status
import requests
from sqlalchemy.orm import Session
from ..database import get_db 
from . import schema, model
from .._Learning_Content import model as Learning_ContentModel
from fastapi import File, UploadFile, Form
import os
import uuid
import shutil
from datetime import datetime, timezone
from fastapi.responses import FileResponse

UPLOAD_DIR = "static/uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)

router = APIRouter(
    prefix="/resources",
    tags=["Files & Images"],
)

# create resource
@router.post("/", status_code=status.HTTP_201_CREATED)
async def create(
    file : UploadFile = File(..., description="File content to upload."),
    content_id : int = Form(..., description="id of this content."),
    db: Session = Depends(get_db)
):
    
    # check if content id exist
    if content_id is not None:
        resource = db.query(Learning_ContentModel.LearningContent).filter(
            Learning_ContentModel.LearningContent.contentID == content_id).first()
        
        if resource is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content not found")
    
    # save to disk
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"{content_id}_{uuid.uuid4()}{file_extension}"
    file_path_on_disk = os.path.join(UPLOAD_DIR, unique_filename)
    
    try:
        with open(file_path_on_disk, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                            detail=f"Failed to save file to disk: {e}")
    finally:
        await file.close()
    
    db_resource = model.FileImage(
        path = file_path_on_disk,
        contentID = content_id,
        upload_at = datetime.now(timezone.utc)
    )
    
    db.add(db_resource)
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Database error during creation: {e}")
    db.refresh(db_resource)
    return {"message": "Resource created successfully"}

#view image
@router.get("/image/{resource_id}")
def get_image(resource_id: int, db: Session = Depends(get_db)):
    # 1. Look up the file record using its primary key
    resource = db.query(model.FileImage).filter(
        model.FileImage.resourceID == resource_id
    ).first()

    if not resource:
        raise HTTPException(status_code=404, detail="Image resource not found")

    # 2. Get the file path
    file_path = resource.path

    # 3. Sanity check: Ensure the file exists on the disk
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found on server disk")

    # 4. Determine the media type (MIME type) based on the file extension
    #    This is important for the browser to display the image correctly
    #    We can use a simple check or the mimetypes library for robustness
    
    # Simple example for common types:
    if file_path.endswith('.png'):
        media_type = 'image/png'
    elif file_path.endswith('.jpg') or file_path.endswith('.jpeg'):
        media_type = 'image/jpeg'
    else:
        media_type = 'application/octet-stream' # Default for unknown types

    return FileResponse(
        path=file_path, 
        media_type=media_type, 
        filename=os.path.basename(file_path) # Optional: suggests the file name to the client
    )

# read resource
@router.get("/{resource_id}/{content_id}", response_model=schema.FileImageRead)
def read(resource_id : int, content_id : int, db : Session = Depends(get_db)):
    resource = db.query(model.FileImage).filter(
        model.FileImage.resourceID == resource_id,
        model.FileImage.contentID == content_id).first()
    
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found")
    
    return resource

# update resource
@router.patch("/{resource_id}/{content_id}", response_model=schema.FileImageRead)
def update(resource_id : int, content_id : int,resource_data: schema.FileImageUpdate, db : Session = Depends(get_db)):
    db_resource = db.query(model.FileImage).filter(
        model.FileImage.resourceID == resource_id,
        model.FileImage.contentID == content_id).first()
    
    if not db_resource:
        raise HTTPException(status_code=404, detail="Resource not found")
    
    update_data = resource_data.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        setattr(db_resource, key, value)
        
    db.commit()
    db.refresh(db_resource)
    
    return db_resource
    
# delete resource
@router.delete("/{resource_id}/{content_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete(resource_id : int, content_id : int, db : Session = Depends(get_db)):
    db_material = db.query(model.FileImage).filter(
        model.FileImage.resourceID == resource_id,
        model.FileImage.contentID == content_id).first()
    
    if not db_material:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Resource not found")
    
    db.delete(db_material)
    db.commit()
    
    return

# helper function
def is_valid_respone(name : str, url : str):
    """
    request to the given endpoint to check if the item exist
    """
    try:
        respone = requests.get(url)
        
        if respone.status_code == status.HTTP_404_NOT_FOUND:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{name} with ID '{respone}' not found"
            )
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Service is currently unavailable: {str(e)}"
        )
        
    return True