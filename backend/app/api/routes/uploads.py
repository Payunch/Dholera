from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

from app.api.deps import require_admin
from app.services.media import save_image_upload, save_pdf_upload

router = APIRouter(dependencies=[Depends(require_admin)])


@router.post("/image", status_code=status.HTTP_201_CREATED)
async def upload_image(file: UploadFile = File(...)) -> dict[str, str]:
    if not file.filename:
        raise HTTPException(status_code=400, detail="Image filename is required.")
    image_url, thumbnail_url = await save_image_upload(file)
    return {"image_url": image_url, "thumbnail_url": thumbnail_url}


@router.post("/pdf", status_code=status.HTTP_201_CREATED)
async def upload_pdf(file: UploadFile = File(...)) -> dict[str, str]:
    if not file.filename:
        raise HTTPException(status_code=400, detail="PDF filename is required.")
    pdf_url = await save_pdf_upload(file)
    return {"pdf_url": pdf_url}

