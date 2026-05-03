from fastapi import APIRouter, Depends, HTTPException, Query, status, BackgroundTasks
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session
import logging

from app.api.deps import get_db, require_admin
from app.core.constants import CATEGORY_OPTIONS, LEAD_STATUS_OPTIONS, PIPELINE_STAGES
from app.models.lead import Lead
from app.models.update import Update
from app.models.user import User
from app.schemas.lead import LeadListResponse, LeadRead, LeadUpdate
from app.schemas.update import (
    AdminDashboardOverview,
    AdminDashboardSummary,
    UpdateCreate,
    UpdateListResponse,
    UpdateRead,
    UpdateUpdate,
)
from app.services.media import remove_media_file
from app.services.update_service import (
    apply_update_payload,
    build_update_query,
    get_featured_update,
)

logger = logging.getLogger(__name__)

router = APIRouter(dependencies=[Depends(require_admin)])

def trigger_notifications(update_title: str, update_slug: str):
    logger.info(f"🔔 [Push Notification] New infrastructure update added: {update_title}")
    logger.info(f"📱 [WhatsApp Automation] Auto-generating CTA context for slug: {update_slug}")
    logger.info("📱 [WhatsApp Automation] Sending alert to CRM admins.")


@router.get("/dashboard", response_model=AdminDashboardOverview)
def get_dashboard_overview(db: Session = Depends(get_db)) -> AdminDashboardOverview:
    total_updates = db.scalar(select(func.count(Update.id))) or 0
    featured_updates = db.scalar(
        select(func.count(Update.id)).where(Update.is_featured.is_(True))
    ) or 0
    total_leads = db.scalar(select(func.count(Lead.id))) or 0
    new_leads = db.scalar(
        select(func.count(Lead.id)).where(Lead.status == "new")
    ) or 0

    recent_leads = (
        db.execute(select(Lead).order_by(Lead.created_at.desc()).limit(6))
        .scalars()
        .all()
    )
    recent_updates = (
        db.execute(select(Update).order_by(Update.created_at.desc()).limit(5))
        .scalars()
        .all()
    )

    return AdminDashboardOverview(
        summary=AdminDashboardSummary(
            total_updates=total_updates,
            featured_updates=featured_updates,
            total_leads=total_leads,
            new_leads=new_leads,
            supported_languages=3,
        ),
        recent_leads=recent_leads,
        recent_updates=recent_updates,
    )


@router.get("/meta")
def get_admin_meta() -> dict[str, list[str]]:
    return {
        "categories": CATEGORY_OPTIONS,
        "lead_statuses": LEAD_STATUS_OPTIONS,
        "pipeline_stages": PIPELINE_STAGES,
    }


@router.get("/updates", response_model=UpdateListResponse)
def list_updates(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=50),
    search: str | None = Query(None),
    category: str | None = Query(None),
    db: Session = Depends(get_db),
) -> UpdateListResponse:
    base_query = build_update_query(db, search=search, category=category)
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

    return UpdateListResponse.from_items(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        featured=get_featured_update(db, category=category),
    )


@router.post("/updates", response_model=UpdateRead, status_code=status.HTTP_201_CREATED)
def create_update(
    payload: UpdateCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
) -> UpdateRead:
    update = Update()
    apply_update_payload(db, update, payload, author=current_user.email)
    db.add(update)
    db.commit()
    db.refresh(update)
    
    background_tasks.add_task(trigger_notifications, update.title_en, update.slug)
    
    return update


@router.put("/updates/{update_id}", response_model=UpdateRead)
def update_update(
    update_id: int,
    payload: UpdateUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
) -> UpdateRead:
    update = db.get(Update, update_id)
    if not update:
        raise HTTPException(status_code=404, detail="Update not found.")

    apply_update_payload(db, update, payload, author=current_user.email)
    db.add(update)
    db.commit()
    db.refresh(update)
    return update


@router.delete("/updates/{update_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_update(update_id: int, db: Session = Depends(get_db)) -> None:
    update = db.get(Update, update_id)
    if not update:
        raise HTTPException(status_code=404, detail="Update not found.")

    remove_media_file(update.image_url)
    remove_media_file(update.thumbnail_url)
    remove_media_file(update.pdf_url)
    db.delete(update)
    db.commit()


@router.get("/leads", response_model=LeadListResponse)
def list_leads(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    search: str | None = Query(None),
    status_filter: str | None = Query(None, alias="status"),
    pipeline_filter: str | None = Query(None, alias="pipeline_stage"),
    db: Session = Depends(get_db),
) -> LeadListResponse:
    query = select(Lead)
    if search:
        token = f"%{search.strip()}%"
        query = query.where(
            or_(
                Lead.name.ilike(token),
                Lead.phone.ilike(token),
                Lead.email.ilike(token),
                Lead.message.ilike(token),
            )
        )
    if status_filter and status_filter != "all":
        query = query.where(Lead.status == status_filter)
    if pipeline_filter and pipeline_filter != "all":
        query = query.where(Lead.pipeline_stage == pipeline_filter)

    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    items = (
        db.execute(
            query.order_by(Lead.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        .scalars()
        .all()
    )
    return LeadListResponse.from_items(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.patch("/leads/{lead_id}", response_model=LeadRead)
def update_lead(
    lead_id: int,
    payload: LeadUpdate,
    db: Session = Depends(get_db),
) -> LeadRead:
    lead = db.get(Lead, lead_id)
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found.")

    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(lead, key, value)
    
    db.add(lead)
    db.commit()
    db.refresh(lead)
    return lead
