from fastapi import APIRouter

from app.api.routes import admin, auth, public, uploads

api_router = APIRouter()
api_router.include_router(public.router, prefix="/public", tags=["Public"])
api_router.include_router(auth.router, prefix="/auth", tags=["Auth"])
api_router.include_router(admin.router, prefix="/admin", tags=["Admin"])
api_router.include_router(uploads.router, prefix="/admin/uploads", tags=["Uploads"])

