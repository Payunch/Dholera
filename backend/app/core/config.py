from functools import cached_property
from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

ROOT_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    APP_NAME: str = "Dholera Growth Evidence API"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "change-this-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
    DATABASE_URL: str = "postgresql+psycopg://postgres:postgres@localhost:5432/dholera_platform"
    BACKEND_CORS_ORIGINS: list[str] | str = Field(default=["http://localhost:5173"])
    BASE_URL: str = "http://localhost:8000"
    FRONTEND_URL: str = "http://localhost:5173"
    WHATSAPP_NUMBER: str = "919999999999"
    MAX_IMAGE_UPLOAD_MB: int = 8
    MAX_PDF_UPLOAD_MB: int = 15
    DEFAULT_ADMIN_NAME: str = "Platform Admin"
    DEFAULT_ADMIN_EMAIL: str = "admin@example.com"
    DEFAULT_ADMIN_PASSWORD: str = "ChangeMe123!"

    model_config = SettingsConfigDict(
        env_file=ROOT_DIR / ".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, value: list[str] | str) -> list[str]:
        if isinstance(value, list):
            return value
        return [item.strip() for item in value.split(",") if item.strip()]

    @cached_property
    def uploads_root(self) -> Path:
        return ROOT_DIR / "uploads"

    @cached_property
    def images_dir(self) -> Path:
        return self.uploads_root / "images"

    @cached_property
    def thumbnails_dir(self) -> Path:
        return self.uploads_root / "thumbnails"

    @cached_property
    def pdfs_dir(self) -> Path:
        return self.uploads_root / "pdfs"


settings = Settings()

