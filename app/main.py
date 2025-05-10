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
