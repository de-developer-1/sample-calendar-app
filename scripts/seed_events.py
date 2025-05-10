from datetime import date
from app.database import SessionLocal
from app.models import Event

db = SessionLocal()
db.add_all([
    Event(title="会議", date=date.today()),
    Event(title="ジム", date=date.today()),
])
db.commit()
