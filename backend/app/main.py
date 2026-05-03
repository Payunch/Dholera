from contextlib import asynccontextmanager
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.router import api_router
from app.core.config import settings
from app.db.base import Lead, Update, User  # noqa: F401
from app.db.session import Base, engine
from app.services.media import ensure_storage_dirs

ensure_storage_dirs()


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(title=settings.APP_NAME, lifespan=lifespan)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    print(
        f"LOG: {request.method} {request.url.path} - Status: {response.status_code} - {process_time:.2f}ms"
    )
    return response


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory=settings.uploads_root), name="uploads")
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/")
def root() -> dict[str, str]:
    return {"message": settings.APP_NAME, "docs": "/docs"}


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok"}
