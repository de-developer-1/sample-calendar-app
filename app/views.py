from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse
from starlette.templating import Jinja2Templates
from datetime import date, timedelta
import calendar

from app.database import SessionLocal
from app.models import Event

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")

def get_month_dates(year, month):
    _, last_day = calendar.monthrange(year, month)
    return [date(year, month, day) for day in range(1, last_day + 1)]

@router.get("/", response_class=HTMLResponse)
async def calendar_view(request: Request):
    today = date.today()
    db = SessionLocal()
    month_dates = get_month_dates(today.year, today.month)

    events = db.query(Event).filter(
        Event.date >= month_dates[0],
        Event.date <= month_dates[-1]
    ).all()

    event_map = {e.date: e.title for e in events}

    return templates.TemplateResponse("calendar.html", {
        "request": request,
        "dates": month_dates,
        "event_map": event_map,
    })

@router.post("/add")
async def add_event(date: str = Form(...), title: str = Form(...)):
    db = SessionLocal()
    event = Event(date=date, title=title)
    db.add(event)
    db.commit()
    return {"message": "Event added"}
