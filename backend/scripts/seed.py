import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from sqlalchemy import select

from app.core.config import settings
from app.core.security import hash_password
from app.db.base import Lead, Update, User  # noqa: F401
from app.db.session import Base, SessionLocal, engine
from app.models.lead import Lead
from app.models.update import Update
from app.models.user import User
from app.services.update_service import apply_update_payload
from app.schemas.update import UpdateCreate


def seed() -> None:
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        admin = db.scalar(select(User).where(User.email == settings.DEFAULT_ADMIN_EMAIL))
        if not admin:
            admin = User(
                name=settings.DEFAULT_ADMIN_NAME,
                email=settings.DEFAULT_ADMIN_EMAIL,
                password_hash=hash_password(settings.DEFAULT_ADMIN_PASSWORD),
                role="admin",
            )
            db.add(admin)
            db.commit()

        if not db.scalar(select(Update.id).limit(1)):
            sample_updates = [
                UpdateCreate(
                    title_en="Linear expressway frontage sees fresh planning activity",
                    title_hi="लिनियर एक्सप्रेसवे फ्रंटेज पर नई प्लानिंग गतिविधि",
                    title_gu="લિનિયર એક્સપ્રેસવે ફ્રન્ટેજ પર નવી આયોજન પ્રવૃત્તિ",
                    desc_en="Recent planning movement around the expressway-facing corridor is improving investor confidence by making connectivity narratives easier to verify on-ground.",
                    desc_hi="एक्सप्रेसवे फेसिंग कॉरिडोर में हाल की प्लानिंग गतिविधि निवेशकों के भरोसे को मजबूत कर रही है।",
                    desc_gu="એક્સપ્રેસવે ફેસિંગ કોરિડોરમાં તાજેતરની આયોજન પ્રવૃત્તિ રોકાણકાર વિશ્વાસ મજબૂત કરી રહી છે.",
                    category="Expressway",
                    tags=["frontage", "mobility", "corridor"],
                    is_featured=True,
                ),
                UpdateCreate(
                    title_en="Industrial belt references strengthen nearby land narrative",
                    title_hi="औद्योगिक बेल्ट के संकेत पास की भूमि कहानी को मजबूत कर रहे हैं",
                    title_gu="ઔદ્યોગિક બેલ્ટના સંકેતો આસપાસની જમીન કથાને મજબૂત કરે છે",
                    desc_en="Industry-linked references remain one of the strongest trust builders for visitors evaluating long-hold land opportunities near planned infrastructure growth.",
                    desc_hi="इन्फ्रास्ट्रक्चर ग्रोथ के पास लंबी अवधि की जमीन में रुचि रखने वालों के लिए औद्योगिक संकेत भरोसा बढ़ाते हैं।",
                    desc_gu="આયોજિત ઈન્ફ્રાસ્ટ્રક્ચર વૃદ્ધિ નજીક લાંબા ગાળાની જમીન તક માટે ઔદ્યોગિક સંકેતો વિશ્વાસ વધારતા રહે છે.",
                    category="Industrial",
                    tags=["industry", "trust", "movement"],
                    is_featured=False,
                ),
                UpdateCreate(
                    title_en="Government corridor references keep momentum visible",
                    title_hi="सरकारी कॉरिडोर संदर्भ विकास की गति को दृश्यमान रखते हैं",
                    title_gu="સરકારી કોરિડોર સંદર્ભો વિકાસની ગતિને દૃશ્યમાન રાખે છે",
                    desc_en="Publicly referenced corridor planning helps prospects interpret the area as an active growth zone rather than a passive land holding story.",
                    desc_hi="सार्वजनिक कॉरिडोर प्लानिंग क्षेत्र को सक्रिय ग्रोथ ज़ोन के रूप में समझने में मदद करती है।",
                    desc_gu="જાહેર કોરિડોર આયોજન વિસ્તારને સક્રિય વૃદ્ધિ ઝોન તરીકે સમજવામાં મદદ કરે છે.",
                    category="Government",
                    tags=["policy", "corridor", "visibility"],
                    is_featured=False,
                ),
            ]
            for payload in sample_updates:
                update = Update()
                apply_update_payload(db, update, payload, author=settings.DEFAULT_ADMIN_EMAIL)
                db.add(update)
            db.commit()

        if not db.scalar(select(Lead.id).limit(1)):
            db.add_all(
                [
                    Lead(
                        name="Riya Shah",
                        phone="+91 9876543210",
                        email="riya@example.com",
                        message="Need price sheet and expressway-side plot options.",
                        source="homepage",
                        status="new",
                        preferred_language="en",
                        cta_type="price-sheet",
                    ),
                    Lead(
                        name="Suresh Patel",
                        phone="+91 9988776655",
                        email="suresh@example.com",
                        message="Interested in scheduling a site visit next week.",
                        source="maps-page",
                        status="site_visit",
                        preferred_language="gu",
                        cta_type="site-visit",
                    ),
                ]
            )
            db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    seed()
