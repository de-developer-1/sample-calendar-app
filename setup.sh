#!/bin/bash

mkdir -p calendar-app/app/static calendar-app/app/templates calendar-app/scripts
cd calendar-app

# requirements.txt
cat <<EOF > requirements.txt
fastapi
uvicorn
jinja2
sqlalchemy
EOF

# Dockerfile
cat <<EOF > Dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY scripts ./scripts

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# docker-compose.yml
cat <<EOF > docker-compose.yml
version: "3.9"

services:
  calendar:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./app:/app/app
      - ./scripts:/app/scripts
    restart: always
EOF

# app/main.py
cat <<EOF > app/main.py
from fastapi import FastAPI
from starlette.staticfiles import StaticFiles
from starlette.templating import Jinja2Templates
from app import views, models
from app.database import engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")

app.include_router(views.router)
EOF

# app/views.py
cat <<EOF > app/views.py
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
EOF

# app/database.py
cat <<EOF > app/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "sqlite:///./calendar.db"

engine = create_engine(
    DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
EOF

# app/models.py
cat <<EOF > app/models.py
from sqlalchemy import Column, Integer, String, Date
from app.database import Base

class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    date = Column(Date, nullable=False)
EOF

# app/templates/calendar.html
cat <<EOF > app/templates/calendar.html
<!DOCTYPE html>
<html>
<head>
    <title>カレンダー</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <h1>{{ dates[0].strftime('%Y年%m月') }}</h1>
    <table>
        <tr>
            {% for d in dates %}
                <td>
                    {{ d.day }}<br>
                    {% if d in event_map %}
                        <div class="event">{{ event_map[d] }}</div>
                    {% endif %}
                </td>
                {% if loop.index % 7 == 0 %}
                    </tr><tr>
                {% endif %}
            {% endfor %}
        </tr>
    </table>

    <h2>予定追加</h2>
    <form method="post" action="/add">
        <input type="date" name="date" required>
        <input type="text" name="title" placeholder="予定" required>
        <button type="submit">追加</button>
    </form>
</body>
</html>
EOF

# app/static/style.css
cat <<EOF > app/static/style.css
body {
    font-family: sans-serif;
    padding: 20px;
}
table {
    border-collapse: collapse;
    width: 100%;
}
td {
    border: 1px solid #ccc;
    padding: 10px;
    vertical-align: top;
    width: 14.2%;
    height: 100px;
}
.event {
    background-color: #4CAF50;
    color: white;
    padding: 4px;
    border-radius: 4px;
    margin-top: 5px;
}
EOF

# scripts/seed_events.py
cat <<EOF > scripts/seed_events.py
from datetime import date
from app.database import SessionLocal
from app.models import Event

db = SessionLocal()
db.add_all([
    Event(title="会議", date=date.today()),
    Event(title="ジム", date=date.today()),
])
db.commit()
EOF

echo "✅ カレンダーアプリのファイル構成を作成しました。"
echo "次に実行: docker-compose up --build"
