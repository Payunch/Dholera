from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator

from app.core.constants import LEAD_STATUS_OPTIONS, PIPELINE_STAGES
from app.schemas.common import PaginationMeta


class LeadCreate(BaseModel):
    name: str = Field(min_length=2, max_length=140)
    phone: str = Field(min_length=7, max_length=30)
    email: EmailStr | None = None
    message: str | None = Field(default=None, max_length=4000)
    source: str | None = Field(default=None, max_length=120)
    preferred_language: str = Field(default="en", max_length=8)
    cta_type: str | None = Field(default=None, max_length=80)
    
    # Marketing Tracking
    utm_source: str | None = Field(default=None, max_length=100)
    utm_medium: str | None = Field(default=None, max_length=100)
    utm_campaign: str | None = Field(default=None, max_length=100)

    @field_validator("preferred_language")
    @classmethod
    def validate_language(cls, value: str) -> str:
        if value not in {"en", "hi", "gu"}:
            return "en"
        return value


class LeadRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    phone: str
    email: str | None
    message: str | None
    source: str | None
    status: str
    pipeline_stage: str
    utm_source: str | None
    utm_medium: str | None
    utm_campaign: str | None
    site_visit_history: list[dict[str, Any]]
    tags: list[str]
    preferred_language: str
    cta_type: str | None
    referrer: str | None
    created_at: datetime
    updated_at: datetime


class LeadUpdate(BaseModel):
    status: str | None = None
    pipeline_stage: str | None = None
    tags: list[str] | None = None
    site_visit_history: list[dict[str, Any]] | None = None

    @field_validator("status")
    @classmethod
    def validate_status(cls, value: str | None) -> str | None:
        if value and value not in LEAD_STATUS_OPTIONS:
            raise ValueError(f"Status must be one of: {', '.join(LEAD_STATUS_OPTIONS)}")
        return value

    @field_validator("pipeline_stage")
    @classmethod
    def validate_pipeline(cls, value: str | None) -> str | None:
        if value and value not in PIPELINE_STAGES:
            raise ValueError(f"Pipeline stage must be one of: {', '.join(PIPELINE_STAGES)}")
        return value


class LeadListResponse(BaseModel):
    items: list[LeadRead]
    meta: PaginationMeta

    @classmethod
    def from_items(
        cls,
        *,
        items: list[object],
        total: int,
        page: int,
        page_size: int,
    ) -> "LeadListResponse":
        return cls(
            items=[LeadRead.model_validate(item) for item in items],
            meta=PaginationMeta.build(total=total, page=page, page_size=page_size),
        )
