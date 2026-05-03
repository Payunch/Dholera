from io import BytesIO
from pathlib import Path
from uuid import uuid4

from fastapi import HTTPException, UploadFile
from PIL import Image, UnidentifiedImageError

from app.core.config import settings


def ensure_storage_dirs() -> None:
    for directory in (
        settings.uploads_root,
        settings.images_dir,
        settings.thumbnails_dir,
        settings.pdfs_dir,
    ):
        directory.mkdir(parents=True, exist_ok=True)


def _normalize_public_path(file_path: Path) -> str:
    relative_path = file_path.relative_to(settings.uploads_root)
    return f"/uploads/{relative_path.as_posix()}"


def _validate_file_size(contents: bytes, limit_mb: int, label: str) -> None:
    limit = limit_mb * 1024 * 1024
    if len(contents) > limit:
        raise HTTPException(status_code=400, detail=f"{label} exceeds {limit_mb} MB.")


async def save_image_upload(file: UploadFile) -> tuple[str, str]:
    contents = await file.read()
    _validate_file_size(contents, settings.MAX_IMAGE_UPLOAD_MB, "Image")

    try:
        image = Image.open(BytesIO(contents))
    except UnidentifiedImageError as exc:
        raise HTTPException(status_code=400, detail="Unsupported image upload.") from exc

    image = image.convert("RGB")

    file_stem = uuid4().hex
    image_path = settings.images_dir / f"{file_stem}.webp"
    thumb_path = settings.thumbnails_dir / f"{file_stem}.webp"

    optimized = image.copy()
    optimized.thumbnail((1600, 1200))
    optimized.save(image_path, format="WEBP", quality=84, method=6)

    thumbnail = image.copy()
    thumbnail.thumbnail((720, 540))
    thumbnail.save(thumb_path, format="WEBP", quality=80, method=6)

    return _normalize_public_path(image_path), _normalize_public_path(thumb_path)


async def save_pdf_upload(file: UploadFile) -> str:
    contents = await file.read()
    _validate_file_size(contents, settings.MAX_PDF_UPLOAD_MB, "PDF")

    suffix = Path(file.filename or "").suffix.lower()
    if suffix != ".pdf":
        raise HTTPException(status_code=400, detail="Only PDF uploads are allowed.")

    file_path = settings.pdfs_dir / f"{uuid4().hex}.pdf"
    file_path.write_bytes(contents)
    return _normalize_public_path(file_path)


def remove_media_file(file_url: str | None) -> None:
    if not file_url or not file_url.startswith("/uploads/"):
        return

    file_path = settings.uploads_root / file_url.replace("/uploads/", "", 1)
    if file_path.exists():
        file_path.unlink()

