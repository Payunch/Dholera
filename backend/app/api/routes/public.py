from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.core.constants import CATEGORY_OPTIONS, LEAD_STATUS_OPTIONS
from app.core.config import settings
from app.models.lead import Lead
from app.models.update import Update
from app.schemas.lead import LeadCreate, LeadRead
from app.schemas.update import UpdateDetailResponse, UpdateListResponse, UpdateRead
from app.services.update_service import build_update_query, get_featured_update, get_related_updates

router = APIRouter()


@router.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": settings.APP_NAME}


@router.get("/meta")
def public_meta() -> dict[str, object]:
    return {
        "categories": CATEGORY_OPTIONS,
        "lead_statuses": LEAD_STATUS_OPTIONS,
        "whatsapp_number": settings.WHATSAPP_NUMBER,
    }


@router.get("/updates", response_model=UpdateListResponse)
def list_public_updates(
    page: int = Query(1, ge=1),
    page_size: int = Query(9, ge=1, le=30),
    search: str | None = Query(None),
    category: str | None = Query(None),
    featured_only: bool = Query(False),
    include_featured: bool = Query(True),
    db: Session = Depends(get_db),
) -> UpdateListResponse:
    base_query = build_update_query(
        db,
        search=search,
        category=category,
        featured_only=featured_only,
    )
    total = db.scalar(select(func.count()).select_from(base_query.subquery())) or 0
    items = (
        db.execute(
            base_query.order_by(Update.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        .scalars()
        .all()
    )

    featured = None
    if include_featured and not featured_only and page == 1:
        featured = get_featured_update(db, category=category)

    return UpdateListResponse.from_items(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        featured=featured,
    )


@router.get("/updates/{slug}", response_model=UpdateDetailResponse)
def get_update_detail(slug: str, db: Session = Depends(get_db)) -> UpdateDetailResponse:
    update = db.scalar(select(Update).where(Update.slug == slug))
    if not update:
        raise HTTPException(status_code=404, detail="Update not found.")

    return UpdateDetailResponse(
        **UpdateRead.model_validate(update).model_dump(),
        related_updates=get_related_updates(db, update),
    )


@router.post("/leads", response_model=LeadRead, status_code=status.HTTP_201_CREATED)
def create_lead(
    payload: LeadCreate,
    request: Request,
    db: Session = Depends(get_db),
) -> LeadRead:
    lead = Lead(
        name=payload.name.strip(),
        phone=payload.phone.strip(),
        email=payload.email.lower().strip() if payload.email else None,
        message=payload.message.strip() if payload.message else None,
        source=payload.source.strip() if payload.source else None,
        status="new",
        pipeline_stage="new",
        preferred_language=payload.preferred_language,
        cta_type=payload.cta_type,
        utm_source=payload.utm_source,
        utm_medium=payload.utm_medium,
        utm_campaign=payload.utm_campaign,
        referrer=str(request.headers.get("referer") or ""),
    )
    db.add(lead)
    db.commit()
    db.refresh(lead)
    return lead


@router.get("/sitemap-data")
def sitemap_data(db: Session = Depends(get_db)) -> dict[str, list[dict[str, str]]]:
    items = (
        db.execute(select(Update).order_by(Update.created_at.desc()))
        .scalars()
        .all()
    )
    return {
        "updates": [
            {
                "slug": item.slug,
                "updated_at": item.updated_at.isoformat() if item.updated_at else "",
            }
            for item in items
        ]
    }

