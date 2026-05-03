from sqlalchemy import or_, select
from sqlalchemy.orm import Session
from slugify import slugify

from app.models.update import Update
from app.schemas.update import UpdateCreate, UpdateUpdate


def _unique_slug(db: Session, base_title: str, current_id: int | None = None) -> str:
    base_slug = slugify(base_title) or "growth-update"
    candidate = base_slug
    suffix = 1

    while True:
        existing = db.scalar(select(Update).where(Update.slug == candidate))
        if not existing or existing.id == current_id:
            return candidate
        suffix += 1
        candidate = f"{base_slug}-{suffix}"


def normalize_tags(tags: list[str]) -> list[str]:
    seen: set[str] = set()
    normalized: list[str] = []
    for tag in tags:
        cleaned = tag.strip()
        if cleaned and cleaned.lower() not in seen:
            normalized.append(cleaned)
            seen.add(cleaned.lower())
    return normalized


def apply_update_payload(
    db: Session,
    update: Update,
    payload: UpdateCreate | UpdateUpdate,
    *,
    author: str | None = None,
) -> Update:
    data = payload.model_dump()
    update.title_en = data["title_en"].strip()
    update.title_hi = (data.get("title_hi") or "").strip() or None
    update.title_gu = (data.get("title_gu") or "").strip() or None
    update.desc_en = data["desc_en"].strip()
    update.desc_hi = (data.get("desc_hi") or "").strip() or None
    update.desc_gu = (data.get("desc_gu") or "").strip() or None
    update.image_url = data.get("image_url") or None
    update.thumbnail_url = data.get("thumbnail_url") or data.get("image_url") or None
    update.pdf_url = data.get("pdf_url") or None
    update.video_url = data.get("video_url") or None
    update.embed_code = data.get("embed_code") or None
    update.category = data["category"].strip()
    update.tags = normalize_tags(data.get("tags") or [])
    update.is_featured = bool(data.get("is_featured"))
    update.slug = _unique_slug(db, update.title_en, current_id=update.id)
    if author:
        update.created_by = author

    if update.is_featured:
        db.execute(
            Update.__table__.update()
            .where(Update.id != update.id)
            .values(is_featured=False)
        )

    return update


def build_update_query(
    db: Session,
    *,
    search: str | None = None,
    category: str | None = None,
    featured_only: bool = False,
):
    del db
    query = select(Update)

    if search:
        token = f"%{search.strip()}%"
        query = query.where(
            or_(
                Update.title_en.ilike(token),
                Update.title_hi.ilike(token),
                Update.title_gu.ilike(token),
                Update.desc_en.ilike(token),
                Update.desc_hi.ilike(token),
                Update.desc_gu.ilike(token),
            )
        )

    if category and category not in {"all", ""}:
        query = query.where(Update.category == category)

    if featured_only:
        query = query.where(Update.is_featured.is_(True))

    return query


def get_featured_update(db: Session, category: str | None = None) -> Update | None:
    query = select(Update).where(Update.is_featured.is_(True))
    if category and category not in {"all", ""}:
        query = query.where(Update.category == category)
    return db.scalar(query.order_by(Update.created_at.desc()))


def get_related_updates(db: Session, update: Update, limit: int = 3) -> list[Update]:
    query = (
        select(Update)
        .where(Update.id != update.id)
        .where(
            or_(
                Update.category == update.category,
                Update.is_featured.is_(True),
            )
        )
        .order_by(Update.created_at.desc())
        .limit(limit)
    )
    return list(db.execute(query).scalars().all())

