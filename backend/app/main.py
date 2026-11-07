from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.core.config import settings
from app.workers.scheduler import register_jobs, scheduler


@asynccontextmanager
async def lifespan(app: FastAPI):
    if settings.run_scheduler:
        register_jobs()
        scheduler.start()
    yield
    if settings.run_scheduler:
        scheduler.shutdown(wait=False)


app = FastAPI(lifespan=lifespan)

# include your routers here, for example:
# app.include_router(auth.router, prefix="/api/v1")