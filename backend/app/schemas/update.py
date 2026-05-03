from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.core.constants import CATEGORY_OPTIONS
from app.schemas.common import PaginationMeta
from app.schemas.lead import LeadRead


class UpdateBase(BaseModel):
    title_en: str = Field(min_length=5, max_length=255)
    title_hi: str | None = Field(default=None, max_length=255)
    title_gu: str | None = Field(default=None, max_length=255)
    desc_en: str = Field(min_length=20)
    desc_hi: str | None = None
    desc_gu: str | None = None
    image_url: str | None = Field(default=None, max_length=255)
    thumbnail_url: str | None = Field(default=None, max_length=255)
    pdf_url: str | None = Field(default=None, max_length=255)
    video_url: str | None = Field(default=None, max_length=255)
    embed_code: str | None = None
    category: str = Field(min_length=3, max_length=60)
    tags: list[str] = Field(default_factory=list)
    is_featured: bool = False

    @field_validator("category")
    @classmethod
    def validate_category(cls, value: str) -> str:
        if value not in CATEGORY_OPTIONS:
            raise ValueError(f"Category must be one of: {', '.join(CATEGORY_OPTIONS)}")
        return value


class UpdateCreate(UpdateBase):
    pass


class UpdateUpdate(UpdateBase):
    pass


class UpdateRead(UpdateBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    slug: str
    created_by: str | None
    created_at: datetime
    updated_at: datetime


class UpdateListResponse(BaseModel):
    items: list[UpdateRead]
    meta: PaginationMeta
    featured: UpdateRead | None = None

    @classmethod
    def from_items(
        cls,
        *,
        items: list[object],
        total: int,
        page: int,
        page_size: int,
        featured: object | None = None,
    ) -> "UpdateListResponse":
        return cls(
            items=[UpdateRead.model_validate(item) for item in items],
            meta=PaginationMeta.build(total=total, page=page, page_size=page_size),
            featured=UpdateRead.model_validate(featured) if featured else None,
        )


class UpdateDetailResponse(UpdateRead):
    related_updates: list[UpdateRead] = Field(default_factory=list)


class AdminDashboardSummary(BaseModel):
    total_updates: int
    featured_updates: int
    total_leads: int
    new_leads: int
    supported_languages: int


class AdminDashboardOverview(BaseModel):
    summary: AdminDashboardSummary
    recent_leads: list[LeadRead]
    recent_updates: list[UpdateRead]
