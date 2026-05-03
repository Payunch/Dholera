from math import ceil

from pydantic import BaseModel


class PaginationMeta(BaseModel):
    total: int
    page: int
    page_size: int
    total_pages: int

    @classmethod
    def build(cls, total: int, page: int, page_size: int) -> "PaginationMeta":
        return cls(
            total=total,
            page=page,
            page_size=page_size,
            total_pages=max(1, ceil(total / page_size)) if page_size else 1,
        )

